"use client";
import { useState } from "react";

export function ReviewForm({ onReview, placeId }: { onReview: () => void; placeId: bigint }) {
  const [rating, setRating] = useState(5);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);

  return (
    <div className="card">
      <h2 className="h2">Add review</h2>
      <div style={{ display: "grid", gap: 8 }}>
        <input className="input" type="number" min={1} max={5} value={rating} onChange={(e) => setRating(Number(e.target.value))} />
        <input className="input" placeholder="Your thoughts..." value={text} onChange={(e) => setText(e.target.value)} />
        <button className="btn" disabled={loading} onClick={() => onReview()}>
          Submit
        </button>
      </div>
    </div>
  );
}
