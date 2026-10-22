import { defineConfig } from "vite";
import { resolve } from "node:path";
import { ddutApiPlugin } from "./server/ddut-api.js";

const proxy = {
  ...Object.fromEntries(Object.entries({
    sso: "https://sso.dut.udn.vn",
    profile: "https://profile.dut.udn.vn",
    timetable: "https://timetable.dut.udn.vn",
    academic: "https://xemdiem.dut.udn.vn",
    tuition: "https://hocphi.dut.udn.vn",
    plo: "https://chuandaura.dut.udn.vn",
    community: "https://doanthanhnien.dut.udn.vn",
  }).map(([name, target]) => [`/dut-api/${name}`, {
    target, changeOrigin: true, secure: true,
    // Keep tuition's trailing-slash redirects inside the proxy so the browser
    // never redirects to another origin and drops its Authorization header.
    followRedirects: name === "tuition",
    rewrite: (path) => path.replace(`/dut-api/${name}`, ""),
  }])),
  "/course-api": {
    target: "https://dangkytinchi.dut.udn.vn",
    changeOrigin: true,
    secure: true,
    rewrite: (path) => path.replace(/^\/course-api/, ""),
  },
};

export default defineConfig({
  plugins: [ddutApiPlugin()],
  server: {
    host: "localhost",
    port: 5173,
    strictPort: true,
    proxy,
  },
  preview: { host: "localhost", port: 4173, strictPort: true, proxy },
  build: {
    rollupOptions: {
      input: {
        main: resolve(import.meta.dirname, "index.html"),
        authCallback: resolve(import.meta.dirname, "auth-callback.html"),
      },
    },
  },
});
