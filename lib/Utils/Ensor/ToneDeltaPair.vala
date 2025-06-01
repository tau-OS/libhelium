namespace He {
    public enum TonePolarity {
        DARKER,
        RELATIVE_DARKER,
        LIGHTER,
        RELATIVE_LIGHTER,
        NEARER,
        FARTHER;
    }

    public enum ToneResolve {
        EXACT,
        NEARER,
        FARTHER;
    }

    public class ToneDeltaPair : Object {
        public DynamicColor role_a;
        public DynamicColor role_b;
        public double delta;
        public TonePolarity polarity;
        public ToneResolve resolve = ToneResolve.EXACT;
        public bool stay_together = true;

        public ToneDeltaPair (DynamicColor role_a,
            DynamicColor role_b,
            double delta,
            TonePolarity? polarity,
            ToneResolve? resolve) {
            this.role_a = role_a;
            this.role_b = role_b;
            this.delta = delta;
            this.polarity = polarity;
            this.resolve = resolve;
        }
    }
}