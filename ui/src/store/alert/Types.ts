import { Sounds } from "../../helpers/SoundsHelper";

export interface AlertState {
    message: string,
    duration: number,
    sound: Sounds,
}
