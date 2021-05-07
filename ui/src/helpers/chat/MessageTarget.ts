export enum MessageTarget {
    CctSayAll = 'all',
    CctSquad = 'squad',
    CctAdmin = 'admin',
}

export var MessageTargetString = {
    [MessageTarget.CctSayAll]: 'All',
    [MessageTarget.CctSquad]: 'Squad',
    [MessageTarget.CctAdmin]: 'Admin',
}

export default MessageTarget;
