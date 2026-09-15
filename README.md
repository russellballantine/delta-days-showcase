# 🎷 Delta Days Album Showcase
### Godot 4 Web Platform Showcase Engine

Welcome to the source repository for the **Delta Days** interactive album showcase. This repository tracks the script layouts, scene tree organization, and interface configurations for the WebGL deployment.

---

## 🌐 Live Production Deployment
The live interactive experience is integrated directly into the official portfolio site:
👉 **[://russellballantine.com](https://://russellballantine.com)**

### Hosting & Infrastructure:
* **Host Engine:** Netlify Pro Production Tier (customized to handle high-fidelity audio asset distribution).
* **Start Overlay:** Configured with a dedicated entry canvas layer so the game engine does not auto-initialize or freeze the browser layout when visitors first open the site.
* **Architecture:** Single-Threaded Godot 4 Web Export, explicitly structured to run smoothly without requiring strict cross-origin server headers (`COOP`/`COEP`).

---

## 🛠️ Game Integration & Control Systems
The interactive tracking and mechanics are managed within the local core layout scripts:

* **Dual-Hand Navigation Scheme:** Players can steer using either hand seamlessly. The system listens for **WASD Keys** (left hand) and **Arrow Keys** (right hand) simultaneously inside `character_body_3d.gd` via:
  ```gdscript
  var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
  ```
* **Camera Tracking Vectors:** Uses WebGL-specific rotational math calculations linked to a refined mouse sensitivity tracking scalar (`0.0015`) for smooth 360-degree environmental look control.

---

## 🌐 Website Embed Code (Bandzoogle / HTML Iframe)
To make sure the mouse look controls capture cleanly inside modern browser clients without security blocks, the HTML embed snippet on the band site utilizes explicit sandbox flags:

```html
<iframe 
    src="https://netlify.app" 
    allow="autoplay; fullscreen; gamepad"
    sandbox="allow-scripts allow-same-origin allow-pointer-lock allow-forms"
    style="width: 100%; height: 100%; border: none;">
</iframe>
```

### Essential Embed Parameters:
* `allow-pointer-lock`: Allows a single left-click inside the game frame to lock the cursor, enabling endless mouse-look rotation without hitting the edge of the window.
* `allow-same-origin`: Maintains consistent asset-loading states between the server pipelines.
