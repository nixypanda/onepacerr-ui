import { defineConfig } from 'vite'

export default defineConfig(async () => {
  const elm = (await import('vite-plugin-elm')).default
  
  return {
    plugins: [elm()],
    server: {
      port: 5173,
      proxy: {
        '/api': {
          target: 'https://srt-n01-rivendell.taila65e7f.ts.net:9469',
          changeOrigin: true,
          secure: false,
          rewrite: (path) => path.replace(/^\/api/, '/api/v1')
        }
      }
    },
    build: {
      outDir: 'dist'
    }
  }
})