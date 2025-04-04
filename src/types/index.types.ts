export type ActionName = 'key_up' | 'key_down' | number;
export type KeyPressEvent = {
    keyCode: number;
    action: ActionName;
    pressedKey: string;
}

export const handleActionName = (action: ActionName) => {
    switch (action) {
        case 0:
        case 'key_down':
            return 'key_down';
        case 1:
        case 'key_up':
            return 'key_up';
        default:
            return action;
    }
}
