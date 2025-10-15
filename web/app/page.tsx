"use client";
import { useState } from "react";
import { PlaceForm } from "@/components/PlaceForm";
import { ReviewForm } from "@/components/ReviewForm";

export default function Home() {
  const [lastPlaceId, setLastPlaceId] = useState<bigint | null>(null);

  return (
    <main className="container">
      <h1 className="h1">SpotBase</h1>
      <div style={{ display: "grid", gap: 12 }}>
        <PlaceForm onCreate={(pid) => setLastPlaceId(pid)} />
        {lastPlaceId && <ReviewForm placeId={lastPlaceId} onReview={() => {}} />}
      </div>
    </main>
  );
}
