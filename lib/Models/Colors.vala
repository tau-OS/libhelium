public enum He.Colors {
    NONE = 0,
    RED = 1,
    ORANGE = 2,
    YELLOW = 3,
    GREEN = 4,
    BLUE = 5,
    INDIGO = 6,
    PURPLE = 7,
    PINK = 8,
    MINT = 9,
    BROWN = 10,
    LIGHT = 11,
    DARK = 12;

    public string to_css_class() {
        switch (this) {
            case RED:
                return "meson-red";

            case ORANGE:
                return "lepton-orange";

            case YELLOW:
                return "electron-yellow";

            case GREEN:
                return "muon-green";

            case BLUE:
                return "proton-blue";

            case INDIGO:
                return "photon-indigo";

            case PURPLE:
                return "tau-purple";

            case PINK:
                return "fermion-pink";

            case MINT:
                return "baryon-mint";

            case BROWN:
                return "gluon-brown";

            case LIGHT:
                return "neutron-light";

            case DARK:
                return "graviton-dark";

            default:
                return "nya";
        }
    }

    public string to_string() {
        return this.to_css_class();
    }
}
