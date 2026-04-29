import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Ginsengfood Admin"
};

export default function AdminHomePage() {
  return (
    <main className="shell">
      <h1>Ginsengfood Operational Admin</h1>
      <p>Repository scaffold only. CODE01 business modules are not implemented yet.</p>
    </main>
  );
}
