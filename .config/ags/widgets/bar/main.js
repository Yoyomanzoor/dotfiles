const { Gdk, Gtk } = imports.gi;
import { App, Service, Utils, Widget } from '../../imports.js';
const { execAsync, exec } = Utils;

import { ModuleLeftSpace } from "./leftspace.js";
import { ModuleMusic } from "./music.js";
import { ModuleRightSpace } from "./rightspace.js";
import { ModuleSystem } from "./system.js";
import { ModulePrayer} from "./prayerspace.js";
import { ModuleClock } from "./clock.js";
import ModuleWorkspaces from "./workspaces.js";
// import { RoundedCorner } from "../../lib/roundedcorner.js";

const left = Widget.Box({
    className: 'bar-sidemodule',
    children: [
        ModuleMusic()
    ],
});

const center = Widget.Box({
    children: [
        ModuleWorkspaces(),
    ],
});

const clock = Widget.Box({
    children: [
        ModuleClock()
    ],
});

const salah = Widget.Box({
    children: [
        ModulePrayer()
    ],
});

const right = Widget.Box({
    className: 'bar-sidemodule',
    children: [ModuleSystem()],
});

export default () => Widget.Window({
    name: 'bar',
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    visible: true,
    child: Widget.CenterBox({
        className: 'bar-bg',
        startWidget: ModuleLeftSpace(),
        centerWidget: Widget.Box({
            className: 'spacing-h-4',
            children: [
                left,
                center,
                clock,
                salah,
                right,
            ]
        }),
        endWidget: ModuleRightSpace(),
        setup: (self) => {
            const styleContext = self.get_style_context();
            const minHeight = styleContext.get_property('min-height', Gtk.StateFlags.NORMAL);
            // execAsync(['bash', '-c', `hyprctl keyword monitor ,addreserved,${minHeight},0,0,0`]).catch(print);
        }
    }),
});
