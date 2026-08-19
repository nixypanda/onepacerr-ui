module Ui.DesignTokens exposing
    ( Colors
    , Spacing
    , colors
    , spacing
    )


type alias Colors =
    { primary : String
    , secondary : String
    , accent : String
    , success : String
    , warning : String
    , error : String
    , muted : String
    , surface : String
    , surfaceVariant : String
    , onPrimary : String
    , onSurface : String
    , onMuted : String
    , border : String
    }


type alias Spacing =
    { xs : Int
    , sm : Int
    , md : Int
    , lg : Int
    , xl : Int
    }


colors : Colors
colors =
    { primary = "#0F1A2E"
    , secondary = "#E53E3E"
    , accent = "#F0A500"
    , success = "#2E7D32"
    , warning = "#F57F17"
    , error = "#C62828"
    , muted = "#757575"
    , surface = "#1A2A4A"
    , surfaceVariant = "#15223E"
    , onPrimary = "#FFFFFF"
    , onSurface = "#E0E0E0"
    , onMuted = "#A0A0A0"
    , border = "#2A3A5A"
    }


spacing : Spacing
spacing =
    { xs = 4
    , sm = 8
    , md = 16
    , lg = 24
    , xl = 32
    }