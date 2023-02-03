#[no_mangle]
pub unsafe extern "C" fn glidesort(x: *mut i32, len: u64) {
  glidesort::sort(std::slice::from_raw_parts_mut(x, len as usize))
}

// Not used: didn't seem faster
#[no_mangle]
pub unsafe extern "C" fn glidesort_buf(x: *mut i32, len: u64, buf: *mut i32) {
  glidesort::sort_with_buffer(
    std::slice::from_raw_parts_mut(x, len as usize),
    std::slice::from_raw_parts_mut(std::mem::transmute(buf), (2*len) as usize)
  )
}
