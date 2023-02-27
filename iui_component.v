module iuicomponent

import ui
import iui
import time
import gg

[heap]
struct IuiComponent {
	id string
pub mut:
	layout &ui.CanvasLayout
	app    &iui.Window
}

[params]
pub struct IuiComponentParams {
	id     string = 'iui'
	window &iui.Window
}

pub struct State {
pub mut:
	window &iui.Window = unsafe { nil }
	comps  map[string]iui.Component
}

pub fn iui_canvaslayout(p IuiComponentParams) &ui.CanvasLayout {
	mut layout := ui.canvas_plus(
		id: ui.component_id(p.id, 'layout')
		delegate_evt_mngr: true
		on_draw: iuic_draw
		on_delegate: iuic_on_delegate
	)
	mut iuic := &IuiComponent{
		id: p.id
		app: p.window
		layout: layout
	}
	ui.component_connect(iuic, layout)
	layout.on_init = iuic_init
	return layout
}

// component access
pub fn iui_component(w ui.ComponentChild) &IuiComponent {
	return unsafe { &IuiComponent(w.component) }
}

pub fn iui_component_from_id(w ui.Window, id string) &IuiComponent {
	return iui_component(w.get_or_panic[ui.Stack](ui.component_id(id, 'layout')))
}

fn iuic_init(layout &ui.CanvasLayout) {
	mut iuic := iui_component(layout)
	if layout.ui.dd is ui.DrawDeviceContext {
		iuic.app.gg = &layout.ui.dd.Context
		iuic.app.graphics_context.gg = &layout.ui.dd.Context
	}
}

fn (mut iuic IuiComponent) draw(mut d ui.DrawDevice, c &ui.CanvasLayout) {
	now := time.now().unix_time_milli()

	// Sort by Z-index; Lower draw first
	iuic.app.components.sort(a.z_index < b.z_index)

	// Draw components
	// mut bar_drawn := false
	for mut com in iuic.app.components {
		com.draw_event_fn(mut iuic.app, com)

		// if com.z_index > 100 && iui.app.show_menu_bar && !bar_drawn {
		// 	mut bar := iui.app.get_bar()
		// 	if bar != voidptr(0) {
		// 		bar.draw(iui.app.graphics_context)
		// 	}
		// 	bar_drawn = true
		// }

		com.draw(iuic.app.graphics_context)
		com.after_draw_event_fn(mut iuic.app, com)
	}

	// Draw Menubar last
	// if iui.app.show_menu_bar && !bar_drawn {
	// 	mut bar := iui.app.get_bar()
	// 	if bar != voidptr(0) {
	// 		bar.draw(iui.app.graphics_context)
	// 	}
	// }

	end := time.now().unix_time_milli()
	if end - iuic.app.last_update > 1000 {
		iuic.app.last_update = end
	}
	iuic.app.frame_time = int(end - now)
}

fn iuic_draw(mut d ui.DrawDevice, c &ui.CanvasLayout) {
	mut iuic := iui_component(c)
	iuic.draw(mut d, c)
}

fn iuic_on_delegate(c &ui.CanvasLayout, e &gg.Event) {
	mut iuic := iui_component(c)
	iui.on_event(e, mut iuic.app)
}
