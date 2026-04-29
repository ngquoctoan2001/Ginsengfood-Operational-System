import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Ginsengfood Shopfloor"
};

export default function ShopfloorHomePage() {
  return (
    <main className="shell">
      <h1>Ginsengfood Shopfloor PWA</h1>
      <p>Repository scaffold only. Offline operational commands are not implemented yet.</p>
    </main>
  );
}
