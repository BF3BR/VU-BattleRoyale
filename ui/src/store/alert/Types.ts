import { Sounds } from "../../helpers/SoundHelper";

export interface AlertState {
    message: string,
    duration: number,
    sound: Sounds,
    date: number|null,
}
