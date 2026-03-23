import { onMount, onCleanup, type JSX } from "solid-js";

type Props = {
  children: JSX.Element;
  class?: string;
  style?: string;
  initialX?: number;
  initialY?: number;
  rotation?: number;
  /** Parallax speed multiplier — 0 = no parallax, 0.05 = subtle, 0.15 = noticeable */
  parallax?: number;
};

export function DraggableArtifact(props: Props) {
  let el!: HTMLDivElement;
  let offsetX = 0;
  let offsetY = 0;
  let currentX = 0;
  let currentY = 0;
  let dragging = false;
  let parallaxY = 0;
  let hasBeenDragged = false;

  function onPointerDown(e: PointerEvent) {
    dragging = true;
    hasBeenDragged = true;
    el.setPointerCapture(e.pointerId);
    offsetX = e.clientX - currentX;
    offsetY = e.clientY - currentY;
    el.style.zIndex = "100";
    el.style.cursor = "grabbing";
    el.style.transition = "none";
    el.classList.remove("wobble-hint");
  }

  function onPointerMove(e: PointerEvent) {
    if (!dragging) return;
    currentX = e.clientX - offsetX;
    currentY = e.clientY - offsetY;
    el.style.transform = `translate(${currentX}px, ${currentY}px) rotate(${props.rotation ?? 0}deg)`;
  }

  function onPointerUp() {
    dragging = false;
    el.style.zIndex = "";
    el.style.cursor = "grab";
    el.style.transition = "transform 0.3s cubic-bezier(0.22, 1, 0.36, 1)";
  }

  function onScroll() {
    if (dragging || hasBeenDragged) return;
    const speed = props.parallax ?? 0.05;
    const rect = el.parentElement?.getBoundingClientRect();
    if (!rect) return;
    // Calculate how far the parent is from viewport center
    const viewCenter = window.innerHeight / 2;
    const parentCenter = rect.top + rect.height / 2;
    const offset = (parentCenter - viewCenter) * speed;
    parallaxY = offset;
    el.style.transform = `translate(0px, ${parallaxY}px) rotate(${props.rotation ?? 0}deg)`;
  }

  onMount(() => {
    el.addEventListener("pointerdown", onPointerDown);
    el.addEventListener("pointermove", onPointerMove);
    el.addEventListener("pointerup", onPointerUp);
    el.addEventListener("pointercancel", onPointerUp);

    if (props.parallax !== 0 && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      window.addEventListener("scroll", onScroll, { passive: true });
    }
  });

  onCleanup(() => {
    el?.removeEventListener("pointerdown", onPointerDown);
    el?.removeEventListener("pointermove", onPointerMove);
    el?.removeEventListener("pointerup", onPointerUp);
    el?.removeEventListener("pointercancel", onPointerUp);
    window.removeEventListener("scroll", onScroll);
  });

  return (
    <div
      ref={el!}
      class={`draggable-artifact ${props.class ?? ""}`}
      style={`cursor: grab; touch-action: none; user-select: none; --r: ${props.rotation ?? 0}deg; transform: rotate(${props.rotation ?? 0}deg); ${props.style ?? ""}`}
    >
      {props.children}
    </div>
  );
}
