const hero = document.querySelector(".hero");
const canvas = document.getElementById("globe");
const wide = window.matchMedia("(min-width: 720px)");
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
const connection = navigator.connection;
const slowLink = !!connection && (connection.saveData || /(^|-)(2g|3g)$/.test(connection.effectiveType || ""));

function webglAvailable() {
  try {
    const probe = document.createElement("canvas");
    return !!(probe.getContext("webgl2") || probe.getContext("webgl"));
  } catch {
    return false;
  }
}

if (hero && canvas && !reduceMotion && !slowLink && webglAvailable()) {
  const load = () => start().catch(() => {});
  if (window.requestIdleCallback) requestIdleCallback(load, { timeout: 1500 });
  else setTimeout(load, 200);
}

async function start() {
  const THREE = await import("https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.min.js");
  const css = getComputedStyle(document.documentElement);
  const colour = (name) => new THREE.Color(css.getPropertyValue(name).trim());

  const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: wide.matches });
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100);
  camera.position.set(0, 0, 9);

  const globe = new THREE.Group();
  scene.add(globe);

  const radius = 2;
  const count = 1400;
  const positions = new Float32Array(count * 3);
  for (let i = 0; i < count; i++) {
    const y = 1 - (i / (count - 1)) * 2;
    const r = Math.sqrt(1 - y * y);
    const theta = Math.PI * (3 - Math.sqrt(5)) * i;
    positions.set([Math.cos(theta) * r * radius, y * radius, Math.sin(theta) * r * radius], i * 3);
  }
  const dots = new THREE.BufferGeometry();
  dots.setAttribute("position", new THREE.BufferAttribute(positions, 3));
  globe.add(new THREE.Points(dots, new THREE.PointsMaterial({ color: colour("--muted"), size: 0.035, transparent: true, opacity: 0.7 })));

  const toVector = (lat, lon) => {
    const phi = (90 - lat) * (Math.PI / 180);
    const theta = (lon + 180) * (Math.PI / 180);
    return new THREE.Vector3(-radius * Math.sin(phi) * Math.cos(theta), radius * Math.cos(phi), radius * Math.sin(phi) * Math.sin(theta));
  };
  const capeTown = toVector(-33.92, 18.42);
  const toronto = toVector(43.65, -79.38);
  const lift = capeTown.clone().add(toronto).normalize().multiplyScalar(radius * 1.9);
  const arc = new THREE.QuadraticBezierCurve3(capeTown, lift, toronto);
  globe.add(new THREE.Mesh(new THREE.TubeGeometry(arc, 80, 0.012, 6), new THREE.MeshBasicMaterial({ color: colour("--red") })));

  const pinGeometry = new THREE.SphereGeometry(0.06, 12, 12);
  const pinMaterial = new THREE.MeshBasicMaterial({ color: colour("--gold") });
  for (const point of [capeTown, toronto]) {
    const pin = new THREE.Mesh(pinGeometry, pinMaterial);
    pin.position.copy(point);
    globe.add(pin);
  }
  const packet = new THREE.Mesh(new THREE.SphereGeometry(0.075, 12, 12), new THREE.MeshBasicMaterial({ color: colour("--red") }));
  globe.add(packet);

  const baseY = 1.9;
  globe.rotation.set(0.35, baseY, 0);

  function layout() {
    const { width, height } = hero.getBoundingClientRect();
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, wide.matches ? 2 : 1.5));
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    globe.position.set(wide.matches ? 2.4 : 0, wide.matches ? 0 : -1.6, 0);
    globe.scale.setScalar(wide.matches ? 1 : 0.8);
  }

  let last = 0;
  function frame(ms) {
    if (ms - last < 33) return;
    last = ms;
    const t = ms / 1000;
    globe.rotation.y = baseY + Math.sin(t * 0.15) * 0.35;
    packet.position.copy(arc.getPoint((t * 0.25) % 1));
    renderer.render(scene, camera);
  }

  let onScreen = true;
  const run = () => renderer.setAnimationLoop(onScreen && !document.hidden ? frame : null);
  new IntersectionObserver(([entry]) => { onScreen = entry.isIntersecting; run(); }).observe(hero);
  document.addEventListener("visibilitychange", run);
  new ResizeObserver(layout).observe(hero);

  layout();
  frame(performance.now());
  hero.classList.add("has-globe");
  run();
}
