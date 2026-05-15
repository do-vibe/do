"use client";

import ProtectedRoute from "@/components/ProtectedRoute";
import { useAuth } from "@/context/AuthContext";

export default function Dashboard() {
  const { user } = useAuth();

  return (
    <ProtectedRoute>
      <div
        style={{
          minHeight: "100dvh",
          background: "#0a1520",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily: "'DM Mono', monospace",
          color: "rgba(255,255,255,0.7)",
          fontSize: "0.85rem",
          letterSpacing: "0.08em",
        }}
      >
        {user?.email}
      </div>
    </ProtectedRoute>
  );
}
