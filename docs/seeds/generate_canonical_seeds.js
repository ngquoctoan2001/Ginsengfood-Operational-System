const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "../..");
const seedDir = path.join(root, "docs/seeds");
const createdAt = "2025-01-01T07:00:00+07:00";

const read = (rel) =>
  fs.readFileSync(path.join(root, rel), "utf8").split(/\r?\n/);
const cells = (line) =>
  line
    .trim()
    .replace(/^\|/, "")
    .replace(/\|$/, "")
    .split("|")
    .map((s) => s.trim());
const sql = (v) => {
  if (v === null || v === undefined) return "NULL";
  const text = String(v).trim();
  if (!text || text === "—" || text === "-") return "NULL";
  return `'${text.replace(/'/g, "''")}'`;
};
const ts = (v) => `'${v}'::timestamptz`;
const num = (v, digits) => {
  if (v === null || v === undefined) return "NULL";
  const text = String(v).trim().replace("%", "").replace(",", ".");
  if (!text || text === "—" || text === "-") return "NULL";
  return Number(text).toFixed(digits);
};
const write = (name, content) =>
  fs.writeFileSync(path.join(seedDir, name), content, "utf8");

const skus = [];
for (const line of read(
  "docs/ginsengfood_sku_recipe_md_pack/01_SKU_CANONICAL_MASTER_GINSENGFOOD.md",
)) {
  if (!/^\|\s*\d+\s*\|/.test(line)) continue;
  const c = cells(line);
  if (c.length < 10 || c[3] === "SKU") continue;
  const groupLetter = c[1];
  const groupCode =
    { A: "SEASONAL", B: "FUNCTIONAL", C: "NOURISHING" }[groupLetter] ||
    groupLetter;
  const isVegan = /Thuần|vegan|VEGAN/i.test(c[6]);
  let proteinSource = c[4]
    .replace(/^Cháo Sâm\s*–\s*/, "")
    .replace(/\s*\(.*$/, "");
  if (isVegan) proteinSource = "Thuần chay";
  skus.push({
    id: Number(c[0]),
    groupLetter,
    groupCode,
    groupName: c[2],
    skuCode: c[3],
    skuNameVi: c[4],
    skuNameEn: c[5],
    veganClassification: isVegan ? "VEGAN" : "NON_VEGAN",
    skuType: isVegan ? "VEGAN" : "SAVORY",
    formulaCode: c[7],
    proteinSource,
  });
}

const ingredients = [];
const ingredientNameByCode = new Map();
for (const line of read(
  "docs/ginsengfood_sku_recipe_md_pack/02_INGREDIENT_CANONICAL_MASTER_GINSENGFOOD.md",
)) {
  if (!/^\|\s*(HRB|ING)_/.test(line)) continue;
  const c = cells(line);
  if (c.length < 7) continue;
  const code = c[0];
  const sourceStatus = c[5];
  const materialStatus =
    sourceStatus === "INACTIVE_NOT_USED_IN_G1" ? "INACTIVE" : "ACTIVE";
  const ingredientStatus =
    code === "ING_THIT_HEO_NAC" ? "LOCKED_OWNER_SEPARATE" : sourceStatus;
  let notes = c[6];
  if (code === "ING_THIT_HEO_NAC") {
    notes =
      `${notes} Owner decision: seed as a separate stock/QC ingredient for B4 G1.`.trim();
  }
  const group = code.startsWith("HRB_") ? "HERB" : "INGREDIENT";
  ingredients.push({
    code,
    name: c[1],
    group,
    sourceGroup: c[2],
    uom: c[3],
    scientificName: c[4],
    materialStatus,
    ingredientStatus,
    notes,
  });
  ingredientNameByCode.set(code, c[1]);
}

const nameToIngredientCode = new Map(
  Object.entries({
    "Sâm Savigin": "HRB_SAM_SAVIGIN",
    "Sâm Savigin – Pouzolzia zeylanica (L.) Benn.": "HRB_SAM_SAVIGIN",
    "Hoài sơn": "HRB_HOAI_SON",
    "Hoài sơn – Dioscorea opposita": "HRB_HOAI_SON",
    "Bạch linh": "HRB_BACH_LINH",
    "Kỷ tử": "HRB_KY_TU",
    "Kỷ tử – Lycium barbarum": "HRB_KY_TU",
    "Táo tàu": "HRB_TAO_TAU",
    "Táo tàu dùng nước hầm": "HRB_TAO_TAU",
    "Gừng nướng": "HRB_GUNG_NUONG",
    "Gừng nướng – Zingiber officinale": "HRB_GUNG_NUONG",
    "Trần bì": "HRB_TRAN_BI",
    "Quế chi": "HRB_QUE_CHI",
    "Đông trùng hạ thảo": "HRB_DONG_TRUNG",
    "Diêm mạch": "ING_DIEM_MACH",
    "Hạt sen": "ING_HAT_SEN",
    "Cá Basa": "ING_CA_BASA",
    "Cá hồi": "ING_CA_HOI",
    "Lươn đồng": "ING_LUON_DONG",
    "Thịt cừu": "ING_THIT_CUU",
    "Rau má": "ING_RAU_MA",
    "Đậu xanh không vỏ": "ING_DAU_XANH_KHONG_VO",
    Vừng: "ING_VUNG",
    "Cá cơm": "ING_CA_COM",
    "Thịt heo": "ING_THIT_HEO",
    "Thịt heo nạc": "ING_THIT_HEO_NAC",
    "Da heo": "ING_DA_HEO",
    "Hàu biển": "ING_HAU_BIEN",
    "Gà ác": "ING_GA_AC",
    "Bào ngư – Haliotis spp.": "ING_BAO_NGU",
    "Nấm đông cô": "ING_NAM_DONG_CO",
    "Cua biển": "ING_CUA_BIEN",
    "Cá ngừ": "ING_CA_NGU",
    Tôm: "ING_TOM",
    "Rong biển": "ING_RONG_BIEN",
    "Rong biển kombu / wakame": "ING_RONG_BIEN",
    "Rong biển kombu / wakame dùng nước hầm": "ING_RONG_BIEN",
    "Thịt gà": "ING_THIT_GA",
    "Thịt bò": "ING_THIT_BO",
    "Gạo (lúa – tôm, rửa sạch)": "ING_GAO_LUA_TOM",
    "Cà rốt thái hạt lựu": "ING_CA_ROT",
    "Bí đỏ thái hạt lựu": "ING_BI_DO",
    "Nấm kim châm cắt khúc 20–30 mm": "ING_NAM_KIM_CHAM",
    "Củ cải trắng thái khúc": "ING_CU_CAI_TRANG",
    "Hành tây chẻ 4": "ING_HANH_TAY",
    "Nước dừa nguyên chất": "ING_NUOC_DUA",
    "Muối biển rang": "ING_MUOI_BIEN_RANG",
    "Tiêu đen rang": "ING_TIEU_DEN_RANG",
    "Tỏi nướng": "ING_TOI_NUONG",
    "Hành lá thái khúc": "ING_HANH_LA",
    "Rễ cần tây thái nhuyễn": "ING_RE_CAN_TAY",
    "Mì chính": "ING_MI_CHINH",
  }),
);

const prepNote = (name) => {
  if (/rửa sạch/.test(name)) return "rửa sạch";
  if (/thái hạt lựu/.test(name)) return "thái hạt lựu";
  if (/cắt khúc 20–30 mm/.test(name)) return "cắt khúc 20–30 mm";
  if (/thái khúc/.test(name)) return "thái khúc";
  if (/chẻ 4/.test(name)) return "chẻ 4";
  if (/thái nhuyễn/.test(name)) return "thái nhuyễn";
  if (/dùng nước hầm/.test(name)) return "dùng nước hầm";
  if (/nướng/.test(name)) return "nướng";
  if (/rang/.test(name)) return "rang";
  return null;
};
const variantNote = (name) =>
  /kombu \/ wakame/.test(name) ? "kombu / wakame" : null;
const usageRole = (section, code) => {
  if (section === "SPECIAL_SKU_COMPONENT") {
    return code.startsWith("HRB_")
      ? "SKU_HERBAL_COMPONENT"
      : "SKU_FUNCTIONAL_COMPONENT";
  }
  if (section === "NUTRITION_BASE") return "NUTRITION_BASE";
  if (section === "BROTH_EXTRACT") return "BROTH_EXTRACT";
  return code === "ING_MI_CHINH" ? "UMAMI" : "SEASONING_FLAVOR";
};

const sectionMap = new Map([
  ["Phần 1", "SPECIAL_SKU_COMPONENT"],
  ["Phần 2", "NUTRITION_BASE"],
  ["Phần 3", "BROTH_EXTRACT"],
  ["Phần 4", "SEASONING_FLAVOR"],
]);
const recipeLines = [];
let currentSku = null;
let currentRecipeCode = null;
let currentSection = null;
let lineNo = 0;
for (const raw of read(
  "docs/ginsengfood_sku_recipe_md_pack/04_RECIPE_G1_OPERATIONAL_20SKU_GINSENGFOOD.md",
)) {
  const line = raw.trim();
  const header = line.match(/^##\s+(.+?)\s+—\s+(.+)$/);
  if (header) {
    currentSku = header[1].trim();
    currentRecipeCode = null;
    currentSection = null;
    lineNo = 0;
    continue;
  }
  if (currentSku && line.startsWith("| Mã công thức |")) {
    currentRecipeCode = cells(line)[1];
    continue;
  }
  if (currentSku && line.startsWith("### Phần")) {
    currentSection = null;
    for (const [key, value] of sectionMap) {
      if (line.includes(key)) {
        currentSection = value;
        break;
      }
    }
    continue;
  }
  if (currentSku && currentSection && /^\|\s*\d+\s*\|/.test(line)) {
    const c = cells(line);
    if (c.length < 6 || c[0] === "STT") continue;
    lineNo += 1;
    const name = c[1];
    if (!nameToIngredientCode.has(name))
      throw new Error(`Missing ingredient mapping for ${name}`);
    const ingredientCode = nameToIngredientCode.get(name);
    const canonicalName = ingredientNameByCode.get(ingredientCode);
    if (!canonicalName)
      throw new Error(`Missing ingredient master for ${ingredientCode}`);
    const noteParts = [];
    if (name !== canonicalName) noteParts.push(`Source display: ${name}`);
    if (c[5] && c[5] !== "—" && c[5] !== "-") noteParts.push(c[5]);
    recipeLines.push({
      recipeCode: currentRecipeCode,
      lineNo,
      section: currentSection,
      ingredientCode,
      ingredientDisplayName: canonicalName,
      quantity: c[2],
      uom: c[3],
      ratio: c[4],
      prepNote: prepNote(name),
      usageRole: usageRole(currentSection, ingredientCode),
      variantNote: variantNote(name),
      ingredientNote: noteParts.length ? noteParts.join(" | ") : null,
    });
  }
}

if (skus.length !== 20)
  throw new Error(`Expected 20 SKU rows, got ${skus.length}`);
if (ingredients.length !== 46)
  throw new Error(`Expected 46 ingredient rows, got ${ingredients.length}`);
if (recipeLines.length !== 433)
  throw new Error(`Expected 433 recipe lines, got ${recipeLines.length}`);

write(
  "06_ref_sku.sql",
  `-- Seed canonical 20 SKU master rows from docs/ginsengfood_sku_recipe_md_pack/01_SKU_CANONICAL_MASTER_GINSENGFOOD.md.
-- Metadata is folded into this file; 07_ref_sku_metadata.sql is archived.

BEGIN;

CREATE TEMP TABLE seed_ref_sku (
    id bigint, sku_code text, sku_name text, sku_name_vi text, sku_name_en text, unit text, is_active boolean,
    vegan_classification text, sku_group text, sku_group_code text, sku_group_name text, sku_type text,
    is_sellable boolean, is_advisory_enabled boolean, is_producible boolean, is_trace_public_enabled boolean,
    protein_source text, created_at timestamptz
) ON COMMIT DROP;

INSERT INTO seed_ref_sku VALUES
${skus.map((s) => `(${s.id}, ${sql(s.skuCode)}, ${sql(s.skuNameVi)}, ${sql(s.skuNameVi)}, ${sql(s.skuNameEn)}, 'EA', TRUE, ${sql(s.veganClassification)}, ${sql(s.groupLetter)}, ${sql(s.groupCode)}, ${sql(s.groupName)}, ${sql(s.skuType)}, TRUE, TRUE, TRUE, TRUE, ${sql(s.proteinSource)}, ${ts(createdAt)})`).join(",\n")};

INSERT INTO ref_sku (id, sku_code, sku_name, sku_name_vi, sku_name_en, unit, is_active, vegan_classification, sku_group, sku_group_code, sku_group_name, sku_type, is_sellable, is_advisory_enabled, is_producible, is_trace_public_enabled, protein_source, created_at, is_deleted)
SELECT id, sku_code, sku_name, sku_name_vi, sku_name_en, unit, is_active, vegan_classification, sku_group, sku_group_code, sku_group_name, sku_type, is_sellable, is_advisory_enabled, is_producible, is_trace_public_enabled, protein_source, created_at, FALSE
FROM seed_ref_sku
ON CONFLICT (sku_code) DO UPDATE SET
    sku_name = EXCLUDED.sku_name,
    sku_name_vi = EXCLUDED.sku_name_vi,
    sku_name_en = EXCLUDED.sku_name_en,
    unit = EXCLUDED.unit,
    is_active = EXCLUDED.is_active,
    vegan_classification = EXCLUDED.vegan_classification,
    sku_group = EXCLUDED.sku_group,
    sku_group_code = EXCLUDED.sku_group_code,
    sku_group_name = EXCLUDED.sku_group_name,
    sku_type = EXCLUDED.sku_type,
    is_sellable = EXCLUDED.is_sellable,
    is_advisory_enabled = EXCLUDED.is_advisory_enabled,
    is_producible = EXCLUDED.is_producible,
    is_trace_public_enabled = EXCLUDED.is_trace_public_enabled,
    protein_source = EXCLUDED.protein_source,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
`,
);

const aliases = [
  ["HRB_SAM_SAVIGIN", "MAT-SAM-SAVIGIN"],
  ["HRB_HOAI_SON", "MAT-HERB-HOAISON"],
  ["HRB_BACH_LINH", "MAT-HERB-BACHLINH"],
  ["HRB_KY_TU", "MAT-HERB-KYTU"],
  ["HRB_TAO_TAU", "MAT-HERB-TAOTAU"],
  ["HRB_GUNG_NUONG", "MAT-HERB-GINGNUONG"],
  ["HRB_TRAN_BI", "MAT-HERB-TRANBI"],
  ["HRB_QUE_CHI", "MAT-HERB-QUECCHI"],
  ["HRB_DONG_TRUNG", "MAT-HERB-DONGTRUNG"],
  ["HRB_HUONG_SAM", "MAT-HERB-HUONGSAM"],
  ["ING_DIEM_MACH", "MAT-HERB-DIEUMACH"],
  ["ING_HAT_SEN", "MAT-HERB-HATSEN"],
  ["ING_CA_BASA", "MAT-PROT-CABASA"],
  ["ING_CA_HOI", "MAT-PROT-CAHOI"],
  ["ING_LUON_DONG", "MAT-PROT-LUONDONQ"],
  ["ING_THIT_CUU", "MAT-PROT-THITCUU"],
  ["ING_RAU_MA", "MAT-HERB-RAUMA"],
  ["ING_DAU_XANH_KHONG_VO", "MAT-VEG-DAUXA"],
  ["ING_VUNG", "MAT-HERB-VUNG"],
  ["ING_CA_COM", "MAT-PROT-CACOM"],
  ["ING_THIT_HEO", "MAT-PROT-THITHEO"],
  ["ING_THIT_HEO_NAC", "MAT-PROT-THITHEO-NAC"],
  ["ING_DA_HEO", "MAT-PROT-DAHEO"],
  ["ING_HAU_BIEN", "MAT-PROT-HAUBIEN"],
  ["ING_GA_AC", "MAT-PROT-GAAC"],
  ["ING_BAO_NGU", "MAT-PROT-BAONGU"],
  ["ING_NAM_DONG_CO", "MAT-HERB-NAMDONGCO"],
  ["ING_CUA_BIEN", "MAT-PROT-CUABIEN"],
  ["ING_CA_NGU", "MAT-PROT-CANGU"],
  ["ING_TOM", "MAT-PROT-TOM"],
  ["ING_RONG_BIEN", "MAT-HERB-RONGBIEN"],
  ["ING_THIT_GA", "MAT-PROT-THITGA"],
  ["ING_THIT_BO", "MAT-PROT-THITBO"],
  ["ING_GAO_LUA_TOM", "MAT-GRAIN-GAOLUATOM"],
  ["ING_CA_ROT", "MAT-VEG-CARROT"],
  ["ING_BI_DO", "MAT-VEG-BIDOBI"],
  ["ING_NAM_KIM_CHAM", "MAT-VEG-NAMKIMCHAM"],
  ["ING_CU_CAI_TRANG", "MAT-VEG-CUCAITRANG"],
  ["ING_HANH_TAY", "MAT-VEG-HANHTAY"],
  ["ING_NUOC_DUA", "MAT-LIQ-NUOCDUA"],
  ["ING_MUOI_BIEN_RANG", "MAT-SEAS-MUOIRANG"],
  ["ING_TIEU_DEN_RANG", "MAT-SEAS-TIEUDEN"],
  ["ING_TOI_NUONG", "MAT-SEAS-TOINUONG"],
  ["ING_HANH_LA", "MAT-SEAS-HANHLAKUC"],
  ["ING_RE_CAN_TAY", "MAT-VEG-RECANHTAY"],
  ["ING_MI_CHINH", "MAT-SEAS-MICHINH"],
];

write(
  "08_op_raw_material.sql",
  `-- Seed canonical ingredient/raw material master from docs/ginsengfood_sku_recipe_md_pack/02_INGREDIENT_CANONICAL_MASTER_GINSENGFOOD.md.
-- Canonical material_code = ingredient_code (HRB_* / ING_*). Legacy MAT-* values are aliases only.

BEGIN;

CREATE TEMP TABLE seed_raw_material (material_code text, ingredient_code text, material_name text, canonical_name text, scientific_name text, raw_material_group text, uom_code text, shelf_life_days integer, spec_json jsonb, material_status text, ingredient_status text, ingredient_notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_raw_material VALUES
${ingredients.map((m) => `(${sql(m.code)}, ${sql(m.code)}, ${sql(m.name)}, ${sql(m.name)}, ${sql(m.scientificName)}, ${sql(m.group)}, ${sql(m.uom)}, NULL, NULL::jsonb, ${sql(m.materialStatus)}, ${sql(m.ingredientStatus)}, ${sql(m.notes)}, ${ts(createdAt)})`).join(",\n")};

-- Retire legacy MAT-* rows from operational truth before assigning ingredient_code uniqueness to canonical rows.
UPDATE op_raw_material
SET ingredient_code = NULL, ingredient_status = 'LEGACY_ALIAS', updated_at = NOW()
WHERE material_code LIKE 'MAT-%';

INSERT INTO op_raw_material (material_code, ingredient_code, material_name, canonical_name, scientific_name, raw_material_group, uom_code, shelf_life_days, spec_json, material_status, ingredient_status, ingredient_notes, created_at, is_deleted)
SELECT material_code, ingredient_code, material_name, canonical_name, scientific_name, raw_material_group, uom_code, shelf_life_days, spec_json, material_status, ingredient_status, ingredient_notes, created_at, FALSE
FROM seed_raw_material
ON CONFLICT (material_code) DO UPDATE SET
    ingredient_code = EXCLUDED.ingredient_code,
    material_name = EXCLUDED.material_name,
    canonical_name = EXCLUDED.canonical_name,
    scientific_name = EXCLUDED.scientific_name,
    raw_material_group = EXCLUDED.raw_material_group,
    uom_code = EXCLUDED.uom_code,
    shelf_life_days = EXCLUDED.shelf_life_days,
    spec_json = EXCLUDED.spec_json,
    material_status = EXCLUDED.material_status,
    ingredient_status = EXCLUDED.ingredient_status,
    ingredient_notes = EXCLUDED.ingredient_notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_raw_material_alias (ingredient_code text, alias_code text, alias_name text, alias_type text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_raw_material_alias VALUES
${aliases.map((a) => `(${sql(a[0])}, ${sql(a[1])}, ${sql(ingredientNameByCode.get(a[0]))}, 'LEGACY_CODE', ${ts(createdAt)})`).join(",\n")};

INSERT INTO op_raw_material_alias (raw_material_id, alias_code, alias_name, alias_type, created_at, is_deleted)
SELECT m.id, a.alias_code, a.alias_name, a.alias_type, a.created_at, FALSE
FROM seed_raw_material_alias a
JOIN op_raw_material m ON m.ingredient_code = a.ingredient_code AND m.is_deleted = FALSE
ON CONFLICT (alias_code, alias_type) DO UPDATE SET
    raw_material_id = EXCLUDED.raw_material_id,
    alias_name = EXCLUDED.alias_name,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

UPDATE op_raw_material
SET material_status = 'DISCONTINUED', ingredient_status = 'LEGACY_ALIAS', is_deleted = TRUE, deleted_at = COALESCE(deleted_at, NOW()), updated_at = NOW()
WHERE material_code LIKE 'MAT-%' AND is_deleted = FALSE;

COMMIT;
`,
);

write(
  "09_ref_recipe_line_group.sql",
  `-- Seed canonical G1 recipe line groups from docs/ginsengfood_sku_recipe_md_pack/07_SEED_DATA_SPEC_SKU_INGREDIENT_RECIPE_GINSENGFOOD.md.
BEGIN;
INSERT INTO ref_recipe_line_group (id, code, name, sort_order, is_active, created_at, is_deleted) VALUES
(1, 'SPECIAL_SKU_COMPONENT', 'Thành phần đặc thù SKU', 10, TRUE, ${ts(createdAt)}, FALSE),
(2, 'NUTRITION_BASE', 'Nguyên liệu nền dinh dưỡng', 20, TRUE, ${ts(createdAt)}, FALSE),
(3, 'BROTH_EXTRACT', 'Rau củ chiết dịch tạo nước hầm', 30, TRUE, ${ts(createdAt)}, FALSE),
(4, 'SEASONING_FLAVOR', 'Nguyên liệu nêm và tạo hương vị', 40, TRUE, ${ts(createdAt)}, FALSE)
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, sort_order = EXCLUDED.sort_order, is_active = TRUE, is_deleted = FALSE, deleted_at = NULL, updated_at = NOW();
COMMIT;
`,
);

write(
  "10_op_production_recipe_g1_headers.sql",
  `-- Seed G1 production recipe headers from canonical 20 SKU pack.
-- G0 is retired/tombstoned and must not be active operational configuration.

BEGIN;

UPDATE op_production_recipe
SET recipe_status = 'DEPRECATED', formula_status = 'RETIRED', source_of_truth = FALSE, retired_at = COALESCE(retired_at, NOW()), updated_at = NOW()
WHERE is_deleted = FALSE AND (formula_version = 'G0' OR recipe_code LIKE 'FML-%-G0');

-- All G1 recipes are PILOT_PERCENT_BASED. Anchor = HRB_SAM_SAVIGIN, baseline 9.000 kg, anchor_ratio_percent 4.620000
-- (matches the canonical SPECIAL_SKU_COMPONENT row across all 20 SKUs in the source pack).
-- ratio_percent semantic in G1 source pack = "% relative to NUTRITION_BASE rice baseline (195 kg = 100%)";
-- it is NOT a normalized "% of total batch" axis. Total batch quantity scales proportionally via
-- anchor_baseline_quantity, not via SUM(ratio_percent)=100. See docs/v2-handoff for the formal note.

CREATE TEMP TABLE seed_g1_recipe (recipe_code text, recipe_name text, sku_code text, recipe_status text, version_number integer, formula_version text, formula_kind text, formula_status text, source_of_truth boolean, approved_by_actor_id bigint, approved_at timestamptz, effective_from timestamptz, recipe_note text, anchor_ingredient_code text, anchor_baseline_quantity numeric(18,3), anchor_uom_code text, anchor_ratio_percent numeric(10,4), created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_g1_recipe VALUES
${skus.map((s) => `(${sql(s.formulaCode)}, ${sql(`${s.skuNameVi} (G1)`)}, ${sql(s.skuCode)}, 'ACTIVE', 1, 'G1', 'PILOT_PERCENT_BASED', 'ACTIVE_OPERATIONAL', TRUE, 1, ${ts(createdAt)}, ${ts(createdAt)}, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', 'HRB_SAM_SAVIGIN', 9.000, 'kg', 4.6200, ${ts(createdAt)})`).join(",\n")};

INSERT INTO op_production_recipe (recipe_code, recipe_name, sku_id, recipe_status, version_number, formula_version, formula_kind, formula_status, source_of_truth, approved_by_actor_id, approved_at, effective_from, recipe_note, anchor_ingredient_id, anchor_baseline_quantity, anchor_uom_code, anchor_ratio_percent, created_at, is_deleted)
SELECT s.recipe_code, s.recipe_name, sku.id, s.recipe_status, s.version_number, s.formula_version, s.formula_kind, s.formula_status, s.source_of_truth, s.approved_by_actor_id, s.approved_at, s.effective_from, s.recipe_note, anchor_mat.id, s.anchor_baseline_quantity, s.anchor_uom_code, s.anchor_ratio_percent, s.created_at, FALSE
FROM seed_g1_recipe s
JOIN ref_sku sku ON sku.sku_code = s.sku_code AND sku.is_deleted = FALSE
LEFT JOIN op_raw_material anchor_mat ON anchor_mat.ingredient_code = s.anchor_ingredient_code AND anchor_mat.is_deleted = FALSE
ON CONFLICT (recipe_code) DO UPDATE SET
    recipe_name = EXCLUDED.recipe_name,
    sku_id = EXCLUDED.sku_id,
    recipe_status = EXCLUDED.recipe_status,
    version_number = EXCLUDED.version_number,
    formula_version = EXCLUDED.formula_version,
    formula_kind = EXCLUDED.formula_kind,
    formula_status = EXCLUDED.formula_status,
    source_of_truth = EXCLUDED.source_of_truth,
    approved_by_actor_id = EXCLUDED.approved_by_actor_id,
    approved_at = EXCLUDED.approved_at,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    retired_by_actor_id = NULL,
    retired_at = NULL,
    recipe_note = EXCLUDED.recipe_note,
    anchor_ingredient_id = EXCLUDED.anchor_ingredient_id,
    anchor_baseline_quantity = EXCLUDED.anchor_baseline_quantity,
    anchor_uom_code = EXCLUDED.anchor_uom_code,
    anchor_ratio_percent = EXCLUDED.anchor_ratio_percent,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
`,
);

write(
  "11_op_recipe_ingredients_g1.sql",
  `-- Seed 433 canonical G1 recipe ingredient lines from docs/ginsengfood_sku_recipe_md_pack/04_RECIPE_G1_OPERATIONAL_20SKU_GINSENGFOOD.md.
-- Uses canonical HRB_* / ING_* ingredient codes and four G1 recipe line groups.

BEGIN;

CREATE TEMP TABLE seed_recipe_ingredient (recipe_code text, line_no integer, recipe_line_group_code text, ingredient_code text, ingredient_display_name text, quantity_per_batch_400 numeric(18,3), ratio_percent numeric(18,6), is_anchor boolean, prep_note text, usage_role text, variant_note text, quantity numeric(18,3), uom_code text, tolerance numeric(18,3), ingredient_note text, ingredient_section text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_recipe_ingredient VALUES
${recipeLines.map((r) => `(${sql(r.recipeCode)}, ${r.lineNo}, ${sql(r.section)}, ${sql(r.ingredientCode)}, ${sql(r.ingredientDisplayName)}, ${num(r.quantity, 3)}, ${num(r.ratio, 6)}, ${r.section === "SPECIAL_SKU_COMPONENT" && r.ingredientCode === "HRB_SAM_SAVIGIN" ? "TRUE" : "FALSE"}, ${sql(r.prepNote)}, ${sql(r.usageRole)}, ${sql(r.variantNote)}, ${num(r.quantity, 3)}, ${sql(r.uom)}, NULL, ${sql(r.ingredientNote)}, ${sql(r.section)}, ${ts(createdAt)})`).join(",\n")};

DO $$
DECLARE missing_count integer;
BEGIN
    SELECT COUNT(*) INTO missing_count
    FROM seed_recipe_ingredient s
    LEFT JOIN op_production_recipe r ON r.recipe_code = s.recipe_code AND r.is_deleted = FALSE
    LEFT JOIN op_raw_material m ON m.ingredient_code = s.ingredient_code AND m.is_deleted = FALSE
    WHERE r.id IS NULL OR m.id IS NULL;
    IF missing_count <> 0 THEN
        RAISE EXCEPTION 'G1 recipe seed has % unresolved recipe/material references', missing_count;
    END IF;
END $$;

WITH active_g1 AS (
    SELECT id, recipe_code FROM op_production_recipe WHERE is_deleted = FALSE AND formula_version = 'G1'
)
UPDATE op_recipe_ingredient ri
SET is_deleted = TRUE, deleted_at = COALESCE(ri.deleted_at, NOW()), updated_at = NOW()
FROM active_g1 r
WHERE ri.recipe_id = r.id
  AND ri.is_deleted = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM seed_recipe_ingredient s WHERE s.recipe_code = r.recipe_code AND s.line_no = ri.line_no
  );

WITH resolved AS (
    SELECT r.id AS recipe_id, m.id AS material_id, s.*
    FROM seed_recipe_ingredient s
    JOIN op_production_recipe r ON r.recipe_code = s.recipe_code AND r.is_deleted = FALSE
    JOIN op_raw_material m ON m.ingredient_code = s.ingredient_code AND m.is_deleted = FALSE
)
UPDATE op_recipe_ingredient ri
SET material_id = resolved.material_id,
    recipe_line_group_code = resolved.recipe_line_group_code,
    ingredient_code = resolved.ingredient_code,
    ingredient_display_name = resolved.ingredient_display_name,
    quantity_per_batch_400 = resolved.quantity_per_batch_400,
    ratio_percent = resolved.ratio_percent,
    is_anchor = resolved.is_anchor,
    prep_note = resolved.prep_note,
    usage_role = resolved.usage_role,
    variant_note = resolved.variant_note,
    quantity = resolved.quantity,
    uom_code = resolved.uom_code,
    tolerance = resolved.tolerance,
    ingredient_note = resolved.ingredient_note,
    ingredient_section = resolved.ingredient_section,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW()
FROM resolved
WHERE ri.recipe_id = resolved.recipe_id AND ri.line_no = resolved.line_no AND ri.is_deleted = FALSE;

WITH resolved AS (
    SELECT r.id AS recipe_id, m.id AS material_id, s.*
    FROM seed_recipe_ingredient s
    JOIN op_production_recipe r ON r.recipe_code = s.recipe_code AND r.is_deleted = FALSE
    JOIN op_raw_material m ON m.ingredient_code = s.ingredient_code AND m.is_deleted = FALSE
)
INSERT INTO op_recipe_ingredient (recipe_id, material_id, line_no, recipe_line_group_code, ingredient_code, ingredient_display_name, quantity_per_batch_400, ratio_percent, is_anchor, prep_note, usage_role, variant_note, quantity, uom_code, tolerance, ingredient_note, ingredient_section, created_at, is_deleted)
SELECT resolved.recipe_id, resolved.material_id, resolved.line_no, resolved.recipe_line_group_code, resolved.ingredient_code, resolved.ingredient_display_name, resolved.quantity_per_batch_400, resolved.ratio_percent, resolved.is_anchor, resolved.prep_note, resolved.usage_role, resolved.variant_note, resolved.quantity, resolved.uom_code, resolved.tolerance, resolved.ingredient_note, resolved.ingredient_section, resolved.created_at, FALSE
FROM resolved
WHERE NOT EXISTS (
    SELECT 1 FROM op_recipe_ingredient ri
    WHERE ri.recipe_id = resolved.recipe_id AND ri.line_no = resolved.line_no AND ri.is_deleted = FALSE
);

COMMIT;
`,
);

write(
  "12_op_sku_operational_config.sql",
  `-- Seed per-SKU operational configuration. Initial go-live active formula version is G1.
BEGIN;
CREATE TEMP TABLE seed_sku_operational_config (sku_code text, active_recipe_code text, recipe_version text, packaging_l1_unit text, packaging_l2_unit text, qc_required boolean, public_trace_enabled boolean, recall_applicable boolean, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_sku_operational_config VALUES
${skus.map((s) => `(${sql(s.skuCode)}, ${sql(s.formulaCode)}, 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, ${ts(createdAt)})`).join(",\n")};

WITH resolved AS (
    SELECT sku.id AS sku_id, seed.*
    FROM seed_sku_operational_config seed
    JOIN ref_sku sku ON sku.sku_code = seed.sku_code AND sku.is_deleted = FALSE
)
INSERT INTO op_sku_operational_config (sku_id, active_recipe_code, recipe_version, packaging_l1_unit, packaging_l2_unit, qc_required, public_trace_enabled, recall_applicable, created_at, is_deleted)
SELECT sku_id, active_recipe_code, recipe_version, packaging_l1_unit, packaging_l2_unit, qc_required, public_trace_enabled, recall_applicable, created_at, FALSE FROM resolved
ON CONFLICT (sku_id) DO UPDATE SET
    active_recipe_code = EXCLUDED.active_recipe_code,
    recipe_version = EXCLUDED.recipe_version,
    packaging_l1_unit = EXCLUDED.packaging_l1_unit,
    packaging_l2_unit = EXCLUDED.packaging_l2_unit,
    qc_required = EXCLUDED.qc_required,
    public_trace_enabled = EXCLUDED.public_trace_enabled,
    recall_applicable = EXCLUDED.recall_applicable,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();
COMMIT;
`,
);

write(
  "13_trade_item_qr_public_trace_misa.sql",
  `-- Seed V2 non-recipe operational config from final/forms source packs.
-- Owner-approved production GTIN/GS1 values are still owner data.
-- One TEST_ONLY_DEV_FIXTURE GTIN/map is seeded for local validation and must not be used as production data.

BEGIN;

CREATE TEMP TABLE seed_trade_item_pending (trade_item_code text, sku_code text, packaging_level text, item_type text, packaging_spec text, status text, notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_trade_item_pending VALUES
${skus.map((s) => `(${sql(`TI-${s.formulaCode.replace(/^FML-/, "").replace(/-G1$/, "")}-RETAIL-PENDING`)}, ${sql(s.skuCode)}, 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', ${ts(createdAt)})`).join(",\n")};

INSERT INTO trade_item (trade_item_code, sku_id, sku_code, packaging_level, item_type, packaging_spec, status, notes, created_at, is_deleted)
SELECT s.trade_item_code, sku.id, s.sku_code, s.packaging_level, s.item_type, s.packaging_spec, s.status, s.notes, s.created_at, FALSE
FROM seed_trade_item_pending s
JOIN ref_sku sku ON sku.sku_code = s.sku_code AND sku.is_deleted = FALSE
ON CONFLICT (trade_item_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    sku_code = EXCLUDED.sku_code,
    packaging_level = EXCLUDED.packaging_level,
    item_type = EXCLUDED.item_type,
    packaging_spec = EXCLUDED.packaging_spec,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

-- DEV/TEST ONLY fixture for local print validation.
-- This is not owner-approved production GTIN/GS1 data.
INSERT INTO op_packaging_spec (
    spec_code,
    sku_id,
    packaging_type,
    inner_unit_qty,
    outer_unit_qty,
    label_template_code,
    spec_status,
    spec_note,
    commercial_unit_type,
    inner_unit_type,
    effective_from,
    effective_to,
    created_at,
    is_deleted
)
SELECT
    'PS-A1-SACHET-DEV-FIXTURE',
    sku.id,
    'SACHET',
    1,
    400,
    'TPL-SACHET-DEV-FIXTURE',
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: local/dev packaging spec for GTIN mapping validation; not production owner data.',
    'SACHET',
    'SACHET',
    '2025-01-01T00:00:00'::timestamp,
    NULL,
    ${ts(createdAt)},
    FALSE
FROM ref_sku sku
WHERE sku.sku_code = 'A1/CS/DM/HS' AND sku.is_deleted = FALSE
ON CONFLICT (spec_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    packaging_type = EXCLUDED.packaging_type,
    inner_unit_qty = EXCLUDED.inner_unit_qty,
    outer_unit_qty = EXCLUDED.outer_unit_qty,
    label_template_code = EXCLUDED.label_template_code,
    spec_status = EXCLUDED.spec_status,
    spec_note = EXCLUDED.spec_note,
    commercial_unit_type = EXCLUDED.commercial_unit_type,
    inner_unit_type = EXCLUDED.inner_unit_type,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO trade_item (
    trade_item_code,
    sku_id,
    sku_code,
    packaging_level,
    item_type,
    packaging_spec,
    status,
    notes,
    created_at,
    is_deleted
)
SELECT
    'TI-A1-RETAIL-DEV-FIXTURE',
    sku.id,
    sku.sku_code,
    'LEVEL_2_DEV_FIXTURE',
    'TEST_ONLY',
    'PS-A1-SACHET-DEV-FIXTURE',
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: active local/dev trade item for print GTIN validation only; replace with owner-approved GTIN before production.',
    ${ts(createdAt)},
    FALSE
FROM ref_sku sku
WHERE sku.sku_code = 'A1/CS/DM/HS' AND sku.is_deleted = FALSE
ON CONFLICT (trade_item_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    sku_code = EXCLUDED.sku_code,
    packaging_level = EXCLUDED.packaging_level,
    item_type = EXCLUDED.item_type,
    packaging_spec = EXCLUDED.packaging_spec,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO trade_item_gtin (
    trade_item_id,
    gtin,
    gs1_company_prefix,
    gtin_status,
    effective_from,
    effective_to,
    is_primary,
    notes,
    created_at,
    is_deleted
)
SELECT
    ti.trade_item_id,
    '8930000000019',
    '8930000',
    'ACTIVE',
    '2025-01-01T00:00:00+07:00'::timestamptz,
    NULL,
    TRUE,
    'TEST_ONLY_DEV_FIXTURE: local/dev GTIN fixture only; not owner-approved production GTIN.',
    ${ts(createdAt)},
    FALSE
FROM trade_item ti
WHERE ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE' AND ti.is_deleted = FALSE
ON CONFLICT (gtin) DO UPDATE SET
    trade_item_id = EXCLUDED.trade_item_id,
    gs1_company_prefix = EXCLUDED.gs1_company_prefix,
    gtin_status = EXCLUDED.gtin_status,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_primary = TRUE,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO packaging_trade_item_map (
    packaging_spec_id,
    trade_item_id,
    is_default,
    status,
    notes,
    created_at,
    is_deleted
)
SELECT
    ps.id,
    ti.trade_item_id,
    TRUE,
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: active local/dev packaging-to-trade-item map for GTIN validation only.',
    ${ts(createdAt)},
    FALSE
FROM op_packaging_spec ps
JOIN trade_item ti ON ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE' AND ti.is_deleted = FALSE
WHERE ps.spec_code = 'PS-A1-SACHET-DEV-FIXTURE' AND ps.is_deleted = FALSE
ON CONFLICT (packaging_spec_id, trade_item_id) DO UPDATE SET
    is_default = TRUE,
    status = 'ACTIVE',
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_qr_registry_status (id bigint, code text, name text, sort_order integer, is_public_trace_eligible boolean, is_terminal boolean, is_active boolean, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_qr_registry_status VALUES
(1, 'GENERATED', 'Generated', 10, FALSE, FALSE, TRUE, ${ts(createdAt)}),
(2, 'QUEUED', 'Queued for print', 20, FALSE, FALSE, TRUE, ${ts(createdAt)}),
(3, 'PRINTED', 'Printed', 30, TRUE, FALSE, TRUE, ${ts(createdAt)}),
(4, 'FAILED', 'Print failed', 40, FALSE, TRUE, TRUE, ${ts(createdAt)}),
(5, 'VOID', 'Voided', 50, FALSE, TRUE, TRUE, ${ts(createdAt)}),
(6, 'REPRINTED', 'Reprinted', 60, TRUE, FALSE, TRUE, ${ts(createdAt)});

INSERT INTO ref_qr_registry_status (id, code, name, sort_order, is_public_trace_eligible, is_terminal, is_active, created_at, is_deleted)
SELECT id, code, name, sort_order, is_public_trace_eligible, is_terminal, is_active, created_at, FALSE
FROM seed_qr_registry_status
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_public_trace_eligible = EXCLUDED.is_public_trace_eligible,
    is_terminal = EXCLUDED.is_terminal,
    is_active = EXCLUDED.is_active,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_public_trace_policy (id bigint, field_group text, public_allowed boolean, policy_note text, source_policy text, sort_order integer, is_active boolean, effective_from timestamptz, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_public_trace_policy VALUES
(1, 'SKU_NAME', TRUE, 'Product SKU/name can be shown publicly.', 'CANONICAL_V2', 10, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(2, 'BATCH_DISPLAY', TRUE, 'Batch display identifiers can be shown publicly.', 'CANONICAL_V2', 20, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(3, 'MFG_EXP', TRUE, 'Manufacturing and expiry display fields can be shown publicly.', 'CANONICAL_V2', 30, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(4, 'PROCESS_PUBLIC_STEP', TRUE, 'Approved public process steps can be shown.', 'CANONICAL_V2', 60, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(5, 'SUPPLIER_SENSITIVE', FALSE, 'Supplier-sensitive details are internal only.', 'CANONICAL_V2', 70, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(6, 'PERSONNEL', FALSE, 'Internal personnel fields are internal only.', 'CANONICAL_V2', 80, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(7, 'COSTING_MISA', FALSE, 'Costing and MISA fields are internal only.', 'CANONICAL_V2', 90, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(8, 'QC_DEFECT_DETAIL', FALSE, 'QC defect details are internal only.', 'CANONICAL_V2', 100, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(9, 'LOSS_VARIANCE', FALSE, 'Loss and variance details are internal only.', 'CANONICAL_V2', 110, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(10, 'VERIFICATION_STATUS', TRUE, 'Public verification status can be shown.', 'CANONICAL_V2', 40, TRUE, ${ts(createdAt)}, ${ts(createdAt)}),
(11, 'USAGE_INSTRUCTION', TRUE, 'Approved public usage instructions can be shown.', 'CANONICAL_V2', 50, TRUE, ${ts(createdAt)}, ${ts(createdAt)});

INSERT INTO op_public_trace_field_policy (id, field_group, public_allowed, policy_note, source_policy, sort_order, is_active, effective_from, effective_to, created_at, is_deleted)
SELECT id, field_group, public_allowed, policy_note, source_policy, sort_order, is_active, effective_from, NULL, created_at, FALSE
FROM seed_public_trace_policy
ON CONFLICT (field_group) DO UPDATE SET
    public_allowed = EXCLUDED.public_allowed,
    policy_note = EXCLUDED.policy_note,
    source_policy = EXCLUDED.source_policy,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_misa_document_mapping (internal_document_type text, misa_document_type text, module_code text, retry_policy_code text, reconcile_policy_code text, is_active boolean, notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_misa_document_mapping VALUES
('RAW_MATERIAL_RECEIPT', 'OWNER_PENDING_RAW_MATERIAL_RECEIPT', 'RAW_MATERIAL', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', ${ts(createdAt)}),
('RAW_MATERIAL_ISSUE', 'OWNER_PENDING_RAW_MATERIAL_ISSUE', 'MANUFACTURING', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', ${ts(createdAt)}),
('FINISHED_GOODS_RECEIPT', 'OWNER_PENDING_FINISHED_GOODS_RECEIPT', 'WAREHOUSE_INVENTORY', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', ${ts(createdAt)});

INSERT INTO op_misa_document_mapping (internal_document_type, misa_document_type, module_code, retry_policy_code, reconcile_policy_code, is_active, notes, created_at, is_deleted)
SELECT internal_document_type, misa_document_type, module_code, retry_policy_code, reconcile_policy_code, is_active, notes, created_at, FALSE
FROM seed_misa_document_mapping
ON CONFLICT (internal_document_type) DO UPDATE SET
    misa_document_type = EXCLUDED.misa_document_type,
    module_code = EXCLUDED.module_code,
    retry_policy_code = EXCLUDED.retry_policy_code,
    reconcile_policy_code = EXCLUDED.reconcile_policy_code,
    is_active = EXCLUDED.is_active,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
`,
);

write(
  "15_seed_validation.sql",
  `-- Canonical Ginsengfood V2 seed validation.
-- Run after docs/seeds/*.sql in sorted non-recursive order.

DO $$
DECLARE
    actual integer;
BEGIN
    SELECT COUNT(*) INTO actual FROM ref_sku WHERE is_deleted = FALSE;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected ref_sku count 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_raw_material
    WHERE is_deleted = FALSE
      AND ingredient_code IS NOT NULL
      AND material_code = ingredient_code
      AND (ingredient_code LIKE 'HRB_%' OR ingredient_code LIKE 'ING_%');
    IF actual <> 46 THEN RAISE EXCEPTION 'Expected canonical ingredient master count 46, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE AND formula_version = 'G1' AND formula_status = 'ACTIVE_OPERATIONAL' AND source_of_truth = TRUE;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected active source-of-truth G1 recipe headers 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1';
    IF actual <> 433 THEN RAISE EXCEPTION 'Expected active G1 recipe lines 433, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE
      AND (formula_version = 'G0' OR recipe_code LIKE 'FML-%-G0')
      AND (formula_status = 'ACTIVE_OPERATIONAL' OR source_of_truth = TRUE OR recipe_status = 'ACTIVE');
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected active operational G0 recipe count 0, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_sku_operational_config c
    JOIN ref_sku s ON s.id = c.sku_id AND s.is_deleted = FALSE
    WHERE c.is_deleted = FALSE AND c.recipe_version = 'G1' AND c.active_recipe_code LIKE 'FML-%-G1';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected SKU operational config G1 count 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'SPECIAL_SKU_COMPONENT';
    IF actual <> 114 THEN RAISE EXCEPTION 'Expected SPECIAL_SKU_COMPONENT lines 114, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'NUTRITION_BASE';
    IF actual <> 99 THEN RAISE EXCEPTION 'Expected NUTRITION_BASE lines 99, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'BROTH_EXTRACT';
    IF actual <> 100 THEN RAISE EXCEPTION 'Expected BROTH_EXTRACT lines 100, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'SEASONING_FLAVOR';
    IF actual <> 120 THEN RAISE EXCEPTION 'Expected SEASONING_FLAVOR lines 120, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE
      AND r.formula_version = 'G1'
      AND ri.recipe_line_group_code NOT IN ('SPECIAL_SKU_COMPONENT', 'NUTRITION_BASE', 'BROTH_EXTRACT', 'SEASONING_FLAVOR');
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every G1 recipe_line_group_code to be canonical, bad rows %', actual; END IF;

    SELECT COUNT(DISTINCT r.id) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1'
      AND ri.ingredient_code = 'HRB_SAM_SAVIGIN'
      AND ri.quantity_per_batch_400 = 9.000;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected Sam Savigin 9.00 kg in 20 G1 recipes, got %', actual; END IF;

    SELECT COUNT(DISTINCT r.id) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1'
      AND ri.ingredient_code = 'ING_MI_CHINH'
      AND ri.quantity_per_batch_400 = 1.900;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected Mi chinh 1.90 kg in 20 G1 recipes, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE
      AND r.recipe_code = 'FML-B4-G1'
      AND ri.ingredient_code = 'ING_THIT_HEO_NAC'
      AND ri.quantity_per_batch_400 = 10.500;
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected FML-B4-G1 to contain Thit heo nac 10.50 kg once, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_raw_material
    WHERE is_deleted = FALSE
      AND material_code = 'MAT-SAM-SAVIGIN'
      AND (material_name ILIKE '%Kỉ tử%' OR material_name ILIKE '%Kỷ tử%' OR material_name ILIKE '%Ky tu%');
    IF actual <> 0 THEN RAISE EXCEPTION 'Bad active legacy MAT-SAM-SAVIGIN -> Ky tu row still exists'; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE AND r.formula_version = 'G1'
    LEFT JOIN op_raw_material m ON m.id = ri.material_id AND m.is_deleted = FALSE AND m.ingredient_code = ri.ingredient_code
    WHERE ri.is_deleted = FALSE AND m.id IS NULL;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every G1 recipe ingredient to resolve to canonical ingredient master, unresolved %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM ref_qr_registry_status
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND code IN ('GENERATED', 'QUEUED', 'PRINTED', 'FAILED', 'VOID', 'REPRINTED');
    IF actual <> 6 THEN RAISE EXCEPTION 'Expected QR registry canonical status count 6, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_public_trace_field_policy
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND public_allowed = TRUE
      AND field_group IN ('SKU_NAME', 'BATCH_DISPLAY', 'MFG_EXP', 'VERIFICATION_STATUS', 'USAGE_INSTRUCTION');
    IF actual <> 5 THEN RAISE EXCEPTION 'Expected public trace allowed field policy count 5, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_public_trace_field_policy
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND public_allowed = FALSE
      AND field_group IN ('SUPPLIER_SENSITIVE', 'PERSONNEL', 'COSTING_MISA', 'QC_DEFECT_DETAIL', 'LOSS_VARIANCE');
    IF actual <> 5 THEN RAISE EXCEPTION 'Expected public trace blocked sensitive field policy count 5, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_misa_document_mapping
    WHERE is_deleted = FALSE
      AND internal_document_type IN ('RAW_MATERIAL_RECEIPT', 'RAW_MATERIAL_ISSUE', 'FINISHED_GOODS_RECEIPT')
      AND retry_policy_code = 'STANDARD_RETRY'
      AND reconcile_policy_code = 'STANDARD_RECONCILE';
    IF actual <> 3 THEN RAISE EXCEPTION 'Expected MISA document mapping scaffold count 3, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM trade_item
    WHERE is_deleted = FALSE
      AND status = 'INACTIVE'
      AND packaging_spec = 'OWNER_PENDING_GTIN_GS1'
      AND trade_item_code LIKE 'TI-%-RETAIL-PENDING';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected owner-pending trade item seed rows 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM trade_item_gtin g
    JOIN trade_item ti ON ti.trade_item_id = g.trade_item_id AND ti.is_deleted = FALSE
    WHERE g.is_deleted = FALSE
      AND g.gtin_status = 'ACTIVE'
      AND g.is_primary = TRUE
      AND g.gtin = '8930000000019'
      AND g.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE'
      AND ti.status = 'ACTIVE'
      AND ti.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%';
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected active TEST_ONLY_DEV_FIXTURE GTIN row 1, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM packaging_trade_item_map m
    JOIN op_packaging_spec ps ON ps.id = m.packaging_spec_id AND ps.is_deleted = FALSE
    JOIN trade_item ti ON ti.trade_item_id = m.trade_item_id AND ti.is_deleted = FALSE
    JOIN trade_item_gtin g ON g.trade_item_id = ti.trade_item_id AND g.is_deleted = FALSE
    WHERE m.is_deleted = FALSE
      AND m.status = 'ACTIVE'
      AND m.is_default = TRUE
      AND m.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ps.spec_code = 'PS-A1-SACHET-DEV-FIXTURE'
      AND ps.spec_note ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE'
      AND g.gtin = '8930000000019'
      AND g.gtin_status = 'ACTIVE';
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected active TEST_ONLY_DEV_FIXTURE packaging_trade_item_map row 1, got %', actual; END IF;
END $$;

SELECT 'canonical seed validation passed' AS result;
`,
);

write(
  "README.md",
  `# Seed SQL

Run these SQL files after applying EF migrations on a fresh local/dev database.

## Active Order

1. \`00_views.sql\` - recreates Operational SQL views lost by EF migration squash.
2. \`01_roles.sql\` - roles.
3. \`02_permissions.sql\` - permissions and role-permission assignments.
4. \`03_admin_user.sql\` - bootstrap admin user and admin role assignments.
5. \`04_ref_uom.sql\` - UOM codes used by current seed data.
6. \`05_ref_category.sql\` - reference categories not owned by the canonical SKU/recipe pack.
7. \`06_ref_sku.sql\` - canonical 20 SKU master rows, including SKU metadata columns.
8. \`08_op_raw_material.sql\` - canonical ingredient/raw-material master using \`HRB_*\` / \`ING_*\` plus \`MAT-*\` aliases.
9. \`09_ref_recipe_line_group.sql\` - four canonical G1 recipe line groups.
10. \`10_op_production_recipe_g1_headers.sql\` - active G1 production recipe headers; retires active G0.
11. \`11_op_recipe_ingredients_g1.sql\` - 433 canonical G1 recipe ingredient lines.
12. \`12_op_sku_operational_config.sql\` - per-SKU operational config pointing to G1.
13. \`13_trade_item_qr_public_trace_misa.sql\` - owner-pending trade item scaffold, one \`TEST_ONLY_DEV_FIXTURE\` GTIN/map for local validation, QR lifecycle, public trace policy, and MISA mapping scaffold.
14. \`14_ref_operational_event_types.sql\` - operational event types.
15. \`15_seed_validation.sql\` - post-seed assertions for canonical G1 go-live data.

\`07_ref_sku_metadata.sql\`, the G0 seed files, and the old G1/MAT-* seed files were removed from the active chain and archived under \`docs/seeds/archive/\` with \`.disabled\` suffixes.

## Local Command

\`\`\`powershell
$env:PGPASSWORD = "<password>"
Get-ChildItem docs/seeds -Filter "*.sql" |
  Sort-Object Name |
  ForEach-Object {
    & "C:\\Program Files\\PostgreSQL\\18\\bin\\psql.exe" \`
      -h localhost \`
      -p 5432 \`
      -U postgres \`
      -d ginsengfood_operational \`
      -v ON_ERROR_STOP=1 \`
      -f $_.FullName
  }
\`\`\`

Run the chain a second time when checking idempotency.

## Canonical Source

- \`docs/ginsengfood_sku_recipe_md_pack/01_SKU_CANONICAL_MASTER_GINSENGFOOD.md\`
- \`docs/ginsengfood_sku_recipe_md_pack/02_INGREDIENT_CANONICAL_MASTER_GINSENGFOOD.md\`
- \`docs/ginsengfood_sku_recipe_md_pack/04_RECIPE_G1_OPERATIONAL_20SKU_GINSENGFOOD.md\`
- \`docs/ginsengfood_sku_recipe_md_pack/07_SEED_DATA_SPEC_SKU_INGREDIENT_RECIPE_GINSENGFOOD.md\`
- \`docs/ginsengfood_sku_recipe_md_pack/08_CONFLICT_REPORT_SKU_RECIPE_INGREDIENT_GINSENGFOOD.md\`
- \`docs/ginsengfood_final_pack_md/02_MASTER_DATA_RULE_PACK_FILE02.md\`
- \`docs/ginsengfood_final_pack_md/11_SEED_MIGRATION_ROUTE_TEST_MATRIX.md\`
- \`docs/ginsengfood_forms_operational_md_pack/06_PRINT_CODE_AND_TRACE_RULES_GINSENGFOOD.md\`
- \`docs/ginsengfood_forms_operational_md_pack/07_ACCOUNTING_MISA_BOUNDARY_GINSENGFOOD.md\`

## Validation Targets

- \`ref_sku\` = 20.
- Canonical ingredient master = 46, with \`ING_THIT_HEO_NAC\` separate.
- Active source-of-truth G1 headers = 20.
- Active G1 recipe lines = 433.
- Active operational G0 = 0.
- SKU operational config points to G1 for 20 SKU.
- G1 section counts: \`SPECIAL_SKU_COMPONENT=114\`, \`NUTRITION_BASE=99\`, \`BROTH_EXTRACT=100\`, \`SEASONING_FLAVOR=120\`.
- \`HRB_SAM_SAVIGIN\` 9.00 kg exists in all 20 G1 recipes.
- \`ING_MI_CHINH\` 1.90 kg exists in all 20 G1 recipes.
- \`FML-B4-G1\` contains \`ING_THIT_HEO_NAC\` 10.50 kg.
- No active bad legacy row where \`MAT-SAM-SAVIGIN\` maps to Ky tu.
- Every active G1 recipe ingredient resolves to a canonical ingredient master row.
- QR registry status seed contains the six canonical states.
- Public trace field policy allows only approved public groups and blocks supplier/personnel/costing/QC-defect/loss groups.
- MISA document mapping scaffold exists for raw material receipt, raw material issue, and finished-goods receipt.
- Trade item scaffold has 20 owner-pending inactive rows.
- Active \`TEST_ONLY_DEV_FIXTURE\` \`trade_item_gtin\` rows = 1.
- Active \`TEST_ONLY_DEV_FIXTURE\` \`packaging_trade_item_map\` rows = 1.

## Notes

- G1 is the initial go-live operational baseline, not the final formula ceiling. Future G2/G3 versions should be approved and activated without mutating historical production snapshots.
- G0 remains historical/research context only and is not active operational seed.
- Active seed execution is non-recursive; do not include \`docs/seeds/archive/\` in seed runs.
- The canonical packs require trade item/GTIN, but they do not provide owner-approved production GTIN/GS1 values. This seed creates inactive owner-pending \`trade_item\` rows plus one active \`TEST_ONLY_DEV_FIXTURE\` \`trade_item_gtin\`/\`packaging_trade_item_map\` for local validation only.
`,
);

console.log(
  `Generated canonical seed files. SKU=${skus.length}, ingredients=${ingredients.length}, recipe_lines=${recipeLines.length}`,
);
