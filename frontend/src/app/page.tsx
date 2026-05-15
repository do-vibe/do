"use client";

import { useEffect, useRef } from "react";

function drawDroplets(canvas: HTMLCanvasElement) {
  const ctx = canvas.getContext("2d");
  if (!ctx) return;
  const W = canvas.width;
  const H = canvas.height;

  ctx.clearRect(0, 0, W, H);

  // Deep teal-dark base gradient
  const bg = ctx.createLinearGradient(0, 0, W * 0.6, H);
  bg.addColorStop(0, "#0c1e2e");
  bg.addColorStop(0.5, "#0e2233");
  bg.addColorStop(1, "#091820");
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, W, H);

  // Ambient teal glow — top right
  const glow1 = ctx.createRadialGradient(W * 0.75, H * 0.15, 0, W * 0.75, H * 0.15, W * 0.55);
  glow1.addColorStop(0, "rgba(20, 80, 90, 0.35)");
  glow1.addColorStop(1, "rgba(0,0,0,0)");
  ctx.fillStyle = glow1;
  ctx.fillRect(0, 0, W, H);

  // Ambient teal glow — bottom left
  const glow2 = ctx.createRadialGradient(W * 0.1, H * 0.85, 0, W * 0.1, H * 0.85, W * 0.4);
  glow2.addColorStop(0, "rgba(10, 55, 70, 0.3)");
  glow2.addColorStop(1, "rgba(0,0,0,0)");
  ctx.fillStyle = glow2;
  ctx.fillRect(0, 0, W, H);

  // Deterministic droplets
  const seed = 42;
  const rng = (n: number) => {
    const x = Math.sin(n + seed) * 43758.5453;
    return x - Math.floor(x);
  };

  const count = 110;
  for (let i = 0; i < count; i++) {
    const x = rng(i * 3.1) * W;
    const y = rng(i * 3.7) * H;
    const r = 3 + rng(i * 4.3) * 22;
    const alpha = 0.06 + rng(i * 5.1) * 0.18;

    // Droplet body with internal refraction gradient
    const grad = ctx.createRadialGradient(x - r * 0.25, y - r * 0.3, r * 0.05, x, y, r);
    grad.addColorStop(0, `rgba(160, 210, 220, ${alpha * 1.8})`);
    grad.addColorStop(0.4, `rgba(80, 140, 160, ${alpha * 0.9})`);
    grad.addColorStop(0.8, `rgba(30, 70, 90, ${alpha * 0.5})`);
    grad.addColorStop(1, `rgba(10, 30, 45, ${alpha * 0.1})`);

    ctx.beginPath();
    ctx.arc(x, y, r, 0, Math.PI * 2);
    ctx.fillStyle = grad;
    ctx.fill();

    // Rim
    ctx.beginPath();
    ctx.arc(x, y, r, 0, Math.PI * 2);
    ctx.strokeStyle = `rgba(160, 210, 230, ${alpha * 0.6})`;
    ctx.lineWidth = 0.5;
    ctx.stroke();

    // Specular highlight on larger droplets
    if (r > 8) {
      const hx = x - r * 0.3;
      const hy = y - r * 0.35;
      const hr = r * 0.22;
      const hgrad = ctx.createRadialGradient(hx, hy, 0, hx, hy, hr);
      hgrad.addColorStop(0, `rgba(255, 255, 255, ${0.55 + rng(i * 6.2) * 0.2})`);
      hgrad.addColorStop(1, "rgba(255,255,255,0)");
      ctx.beginPath();
      ctx.arc(hx, hy, hr, 0, Math.PI * 2);
      ctx.fillStyle = hgrad;
      ctx.fill();
    }
  }

  // Condensation streaks
  for (let i = 0; i < 8; i++) {
    const x = rng(i * 9.1 + 200) * W;
    const y1 = rng(i * 8.3 + 100) * H * 0.6;
    const y2 = y1 + 20 + rng(i * 7.7) * 60;
    const alpha = 0.07 + rng(i * 6.1) * 0.1;
    ctx.beginPath();
    ctx.moveTo(x, y1);
    ctx.lineTo(x + rng(i * 5.5) * 4 - 2, y2);
    ctx.strokeStyle = `rgba(160, 210, 220, ${alpha})`;
    ctx.lineWidth = 0.8 + rng(i * 4.4);
    ctx.stroke();
  }
}

export default function Home() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const contentRef = useRef<HTMLElement>(null);
  const footerRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const resize = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
      drawDroplets(canvas);
    };

    resize();
    window.addEventListener("resize", resize);
    return () => window.removeEventListener("resize", resize);
  }, []);

  useEffect(() => {
    contentRef.current?.classList.add("visible");
    footerRef.current?.classList.add("visible");
  }, []);

  const handleSignIn = () => {
    window.location.href = `${process.env.NEXT_PUBLIC_API_URL}/auth/google`;
  };

  return (
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,300;0,400;0,500;1,300&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;1,9..40,300&display=swap');

        .sp-root {
          position: relative;
          min-height: 100dvh;
          width: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          overflow: hidden;
          background: #0a1520;
          font-family: 'DM Sans', sans-serif;
        }

        .sp-canvas {
          position: absolute;
          inset: 0;
          width: 100%;
          height: 100%;
        }

        .sp-content {
          position: relative;
          z-index: 10;
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 2rem 1.5rem;
          text-align: center;
          opacity: 0;
          transform: translateY(16px);
          transition: opacity 0.9s ease 0.3s, transform 0.9s ease 0.3s;
        }

        .sp-content.visible {
          opacity: 1;
          transform: translateY(0);
        }

        .sp-title {
          font-family: 'DM Mono', monospace;
          font-weight: 300;
          font-size: clamp(3.5rem, 12vw, 6.5rem);
          color: #ffffff;
          letter-spacing: 0.04em;
          line-height: 1;
          margin: 0 0 2.75rem;
          text-shadow: 0 2px 40px rgba(0, 0, 0, 0.5);
        }

        .sp-title .dim {
          opacity: 0.45;
        }

        .sp-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;
          padding: 0.875rem 2.25rem;
          border-radius: 9999px;
          border: 1px solid rgba(255, 255, 255, 0.22);
          background: rgba(255, 255, 255, 0.08);
          backdrop-filter: blur(18px);
          -webkit-backdrop-filter: blur(18px);
          color: #ffffff;
          font-family: 'DM Sans', sans-serif;
          font-size: 1rem;
          font-weight: 400;
          letter-spacing: 0.02em;
          cursor: pointer;
          transition: background 0.2s ease, border-color 0.2s ease, transform 0.15s ease;
          margin-bottom: 3rem;
          text-decoration: none;
          white-space: nowrap;
        }

        .sp-btn:hover {
          background: rgba(255, 255, 255, 0.14);
          border-color: rgba(255, 255, 255, 0.38);
          transform: translateY(-2px);
        }

        .sp-btn:active {
          transform: translateY(0);
        }

        .sp-tagline {
          font-family: 'DM Sans', sans-serif;
          font-size: clamp(1.05rem, 3.5vw, 1.3rem);
          font-weight: 300;
          font-style: italic;
          color: rgba(255, 255, 255, 0.6);
          letter-spacing: 0.01em;
          line-height: 1.5;
          max-width: 28ch;
          margin: 0;
        }

        .sp-footer {
          position: absolute;
          bottom: 1.75rem;
          left: 0;
          right: 0;
          display: flex;
          justify-content: center;
          z-index: 10;
          opacity: 0;
          transition: opacity 0.9s ease 0.9s;
        }

        .sp-footer.visible {
          opacity: 1;
        }

        .sp-footer-text {
          font-family: 'DM Mono', monospace;
          font-size: 0.7rem;
          font-weight: 300;
          color: rgba(255, 255, 255, 0.22);
          letter-spacing: 0.12em;
          text-transform: uppercase;
        }

        @media (max-width: 480px) {
          .sp-title { margin-bottom: 2.25rem; }
          .sp-btn { padding: 0.875rem 1.75rem; margin-bottom: 2.5rem; }
        }
      `}</style>

      <div className="sp-root">
        <canvas ref={canvasRef} className="sp-canvas" aria-hidden="true" />

        <main ref={contentRef} className="sp-content">
          <h1 className="sp-title">
            <span className="dim">-[</span>:do:<span className="dim">]-</span>
          </h1>

          <button className="sp-btn" onClick={handleSignIn} aria-label="Sign in with Google">
            <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            sign in with Google
          </button>

          <p className="sp-tagline">a new way to get things done</p>
        </main>

        <footer ref={footerRef} className="sp-footer">
          <span className="sp-footer-text">powered by claude</span>
        </footer>
      </div>
    </>
  );
}
