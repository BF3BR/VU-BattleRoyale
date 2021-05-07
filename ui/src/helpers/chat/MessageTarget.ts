export enum MessageTarget {
    CctSayAll = 'all',
    CctSquad = 'squad',
}

export var MessageTargetString = {
    [MessageTarget.CctSayAll]: 'All',
    [MessageTarget.CctSquad]: 'Squad',
}

export default MessageTarget;
