use std::env;

fn main() {
    let path = env::args().nth(1).expect("Usage: rust_compare <image_path>");
    let img = image::open(&path)
        .unwrap_or_else(|e| panic!("Failed to open {path}: {e}"))
        .to_rgb8();
    let input = okmain::InputImage::try_from(&img).unwrap();
    let colors = okmain::colors(input);

    print!("[");
    for (i, c) in colors.iter().enumerate() {
        if i > 0 {
            print!(", ");
        }
        print!("[{}, {}, {}]", c.r, c.g, c.b);
    }
    println!("]");
}
