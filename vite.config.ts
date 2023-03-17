import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import * as path from "node:path";

export default defineConfig({
  plugins: [RubyPlugin()],
  build: { emptyOutDir: true },
  css: {
    preprocessorOptions: {
      scss: {
        includePaths: ["./node_modules/govuk-frontend/"],
        quietDeps: true,
      },
      devSourcemaps: true,
    },
  },
  resolve: {
    alias: {
      "@govuk": path.resolve(__dirname, "node_modules/govuk-frontend/govuk"),
      "@images": path.resolve(__dirname, "app/frontend/images"),
    },
  },
});
