"use client";
import { useState } from "react";

export function PlaceForm({ onCreate }: { onCreate: (placeId: bigint) => void }) {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [location, setLocation] = useState("");
  const [loading, setLoading] = useState(false);

  return (
    <div className="card">
      <h2 className="h2">Create place</h2>
      <div style={{ display: "grid", gap: 8 }}>
        <input className="input" placeholder="Name" value={name} onChange={(e) => setName(e.target.value)} />
        <input className="input" placeholder="Description" value={description} onChange={(e) => setDescription(e.target.value)} />
        <input className="input" placeholder="Location (lat,long or text)" value={location} onChange={(e) => setLocation(e.target.value)} />
        <button className="btn" disabled={loading} onClick={() => onCreate(1n)}>
          Create
        </button>
      </div>
    </div>
  );
}
