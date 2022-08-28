// https://riptutorial.com/rust/example/24222/displaying-raw-pointers
// Create some data, a raw pointer pointing to it and a null pointer
// https://doc.rust-lang.org/stable/std/primitive.slice.html#method.as_mut_ptr
// rust 1.61_as_mut_ptr

use std::ptr;
fn main() {
    let x = &mut [1, 2, 4];
    let x_ptr = x.as_mut_ptr();

    unsafe {
        for i in 0..x.len() {
            *x_ptr.add(i) += 2;
        }
    }

    println!("x_ptr address : {x_ptr:p}");

    let data: u32 = 42;
    let raw_ptr = &data as *const u32;
    let null_ptr = ptr::null() as *const u32;

    // the {:p} mapping shows pointer values as hexadecimal memory addresses
    println!("Data address: {:p}", &data);
    println!("Raw pointer address: {:p}", raw_ptr);
    println!("Null pointer address: {:p}", null_ptr);
}
