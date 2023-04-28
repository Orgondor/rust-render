mod app_window;

fn main() {
    pollster::block_on(app_window::run());
}
