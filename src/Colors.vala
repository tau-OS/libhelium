public enum He.Colors {
    NONE = 0,
    RED,
    ORANGE,
    YELLOW,
    GREEN,
    BLUE,
    INDIGO,
    PURPLE,
    PINK,
    MINT,
    BROWN,
    LIGHT,
    DARK;

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
