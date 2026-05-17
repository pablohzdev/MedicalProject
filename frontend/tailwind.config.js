// tailwind.config.js
const tailwindConfig = {
  darkMode: "class",
  theme: {
    extend: {
      "colors": {
                    "on-error-container": "#93000a",
                    "on-secondary-container": "#00217a",
                    "surface-container-high": "#dce9ff",
                    "primary": "#004ac6",
                    "secondary": "#3755c3",
                    "on-primary-fixed-variant": "#003ea8",
                    "surface-variant": "#d3e4fe",
                    "tertiary-container": "#bc4800",
                    "surface-tint": "#0053db",
                    "tertiary": "#943700",
                    "surface-dim": "#cbdbf5",
                    "surface-container-low": "#eff4ff",
                    "on-secondary": "#ffffff",
                    "primary-container": "#2563eb",
                    "on-surface": "#0b1c30",
                    "on-primary-fixed": "#00174b",
                    "inverse-surface": "#213145",
                    "background": "#f8f9ff",
                    "on-tertiary-fixed": "#360f00",
                    "inverse-on-surface": "#eaf1ff",
                    "inverse-primary": "#b4c5ff",
                    "surface-container-highest": "#d3e4fe",
                    "on-secondary-fixed": "#001453",
                    "on-surface-variant": "#434655",
                    "secondary-fixed": "#dde1ff",
                    "on-primary": "#ffffff",
                    "tertiary-fixed": "#ffdbcd",
                    "on-tertiary": "#ffffff",
                    "on-secondary-fixed-variant": "#173bab",
                    "on-error": "#ffffff",
                    "surface": "#f8f9ff",
                    "secondary-fixed-dim": "#b8c4ff",
                    "secondary-container": "#708cfd",
                    "outline": "#737686",
                    "on-background": "#0b1c30",
                    "error": "#ba1a1a",
                    "tertiary-fixed-dim": "#ffb596",
                    "primary-fixed": "#dbe1ff",
                    "on-tertiary-fixed-variant": "#7d2d00",
                    "outline-variant": "#c3c6d7",
                    "primary-fixed-dim": "#b4c5ff",
                    "on-primary-container": "#eeefff",
                    "surface-bright": "#f8f9ff",
                    "error-container": "#ffdad6",
                    "surface-container-lowest": "#ffffff",
                    "surface-container": "#e5eeff",
                    "on-tertiary-container": "#ffede6"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "xxl": "48px",
                    "md": "16px",
                    "gutter": "24px",
                    "container-max": "1280px",
                    "xl": "32px",
                    "xs": "4px",
                    "unit": "4px",
                    "sm": "8px",
                    "lg": "24px"
            },
            "fontFamily": {
                    "headline-lg": ["Inter"],
                    "body-md": ["Inter"],
                    "data-mono": ["JetBrains Mono"],
                    "display": ["Inter"],
                    "body-lg": ["Inter"],
                    "label-md": ["Inter"],
                    "headline-md": ["Inter"],
                    "body-sm": ["Inter"]
            },
            "fontSize": {
                    "headline-lg": ["28px", {"lineHeight": "36px", "letterSpacing": "-0.01em", "fontWeight": "600"}],
                    "body-md": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "data-mono": ["14px", {"lineHeight": "20px", "fontWeight": "500"}],
                    "display": ["36px", {"lineHeight": "44px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "body-lg": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                    "label-md": ["12px", {"lineHeight": "16px", "letterSpacing": "0.05em", "fontWeight": "600"}],
                    "headline-md": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "body-sm": ["12px", {"lineHeight": "16px", "fontWeight": "400"}]
            }
      // resto de la config
    }
  }
}