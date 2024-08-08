namespace He {
    public enum TonePolarity {
        DARKER,
        LIGHTER,
        NEARER,
        FARTHER;
    }

    public class ToneDeltaPair : Object {
        public DynamicColor role_a;
        public DynamicColor role_b;
        public double delta;
        public TonePolarity polarity;
        public bool stay_together;

        public ToneDeltaPair(DynamicColor role_a,
            DynamicColor role_b,
            double delta,
            TonePolarity? polarity,
            bool stay_together) {
            this.role_a = role_a;
            this.role_b = role_b;
            this.delta = delta;
            this.polarity = polarity;
            this.stay_together = stay_together;
        }
    }
}