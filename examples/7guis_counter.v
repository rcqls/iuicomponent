import iuicomponent as iuic
import iui
import ui

const (
	win_width  = 430
	win_height = 50
)
[console]
fn main() {
	mut state := iuic.State{}
	create_iui(mut state, 200, 0, 230, 55)
	win := ui.window(
		width: win_width
		height: win_height
		title: 'Counter'
		mode: .resizable
		// state: app
		children: [
			ui.row(
				spacing: 5
				margin_: 10
				widths: [ui.stretch, 230]
				heights: ui.stretch
				children: [
					ui.button(id: 'btn', text: 'v ui'),
					iuic.iui_canvaslayout(
						window: state.window
					),
				]
			),
		]
	)
	ui.run(win)
}

fn create_iui(mut state iuic.State, x int, y int, width int, height int) {
	// Create Window
	mut window := iui.window(iui.get_system_theme(), 'Counter', width, height)
	// Create an HBox
	mut hbox := iui.hbox(window)
	hbox.set_bounds(x, y, width, height)

	// Create the Label
	mut lbl := iui.label(window, '0')
	lbl.set_bounds(42, 20, 0, 0)
	lbl.pack()

	// Create Count Button
	btn := iui.button(window, 'Count', iui.ButtonConfig{
		bounds: iui.Bounds{64, 13, 0, 0}
		click_event_fn: on_click
		should_pack: true
		user_data: &lbl
	})

	// Add to HBox
	hbox.add_child(lbl)
	hbox.add_child(btn)
	hbox.pack()
	window.add_child(hbox)
	// register state
	state.window = window
	state.comps["lbl"] = lbl
}

// on click event function
// The Label we want to update is sent as data.
fn on_click(win &iui.Window, btn voidptr, data voidptr) {
	mut lbl := &iui.Label(data)
	current_value := lbl.text.int()
	lbl.text = (current_value + 1).str()
	lbl.pack()
}
