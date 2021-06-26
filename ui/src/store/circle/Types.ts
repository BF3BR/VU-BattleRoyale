import Circle from "../../helpers/CircleHelper";

export interface CircleState {
    innerCircle: Circle|null;
    outerCircle: Circle|null;
    subPhaseIndex: number;
}
