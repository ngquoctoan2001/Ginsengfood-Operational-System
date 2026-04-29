import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Ginsengfood Public Trace"
};

export default function PublicTraceHomePage() {
  return (
    <main className="shell">
      <h1>Ginsengfood Public Trace</h1>
      <p>Repository scaffold only. Public trace APIs and whitelist projection are not implemented yet.</p>
    </main>
  );
}
