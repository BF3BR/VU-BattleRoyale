export function sendToLua(event: string, value?: any) {
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            return;
        }
    }

    if (value !== null) {
        WebUI.Call('DispatchEventLocal', event, value);
    } else {
        WebUI.Call('DispatchEventLocal', event);
    }
}
