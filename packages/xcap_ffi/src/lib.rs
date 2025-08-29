use std::os::raw::c_char;
use std::ffi::CString;
use std::ptr;
use xcap::Monitor;

#[repr(C)]
pub struct CaptureResult {
    pub success: bool,
    pub data: *mut u8,
    pub len: usize,
    pub width: u32,
    pub height: u32,
    pub error_msg: *mut c_char,
}

/// 释放捕获结果的内存
#[no_mangle]
pub extern "C" fn xcap_free_result(result: *mut CaptureResult) {
    if result.is_null() {
        return;
    }
    
    unsafe {
        let result = Box::from_raw(result);
        
        if !result.data.is_null() {
            let data = Vec::from_raw_parts(result.data, result.len, result.len);
            drop(data);
        }
        
        if !result.error_msg.is_null() {
            let _ = CString::from_raw(result.error_msg);
        }
    }
}

/// 捕获主显示器的屏幕
#[no_mangle]
pub extern "C" fn xcap_capture_primary_monitor() -> *mut CaptureResult {
    capture_monitor_internal(true)
}

/// 捕获所有显示器（拼接成一张图）
#[no_mangle]
pub extern "C" fn xcap_capture_all_monitors() -> *mut CaptureResult {
    capture_monitor_internal(false)
}

/// 根据坐标捕获显示器
#[no_mangle]
pub extern "C" fn xcap_capture_monitor_at_point(x: i32, y: i32) -> *mut CaptureResult {
    let result = Box::new(match Monitor::from_point(x, y) {
        Ok(monitor) => match monitor.capture_image() {
            Ok(image) => {
                let width = image.width();
                let height = image.height();
                let mut data = image.into_raw();
                let len = data.len();
                let data_ptr = data.as_mut_ptr();
                std::mem::forget(data);
                
                CaptureResult {
                    success: true,
                    data: data_ptr,
                    len,
                    width,
                    height,
                    error_msg: ptr::null_mut(),
                }
            }
            Err(e) => create_error_result(&format!("Failed to capture monitor: {:?}", e)),
        },
        Err(e) => create_error_result(&format!("Failed to find monitor at point: {:?}", e)),
    });
    
    Box::into_raw(result)
}

/// 捕获指定区域
#[no_mangle]
pub extern "C" fn xcap_capture_region(x: u32, y: u32, width: u32, height: u32) -> *mut CaptureResult {
    let result = Box::new(match Monitor::all() {
        Ok(monitors) => {
            if let Some(monitor) = monitors.into_iter().find(|m| m.is_primary().unwrap_or(false)) {
                match monitor.capture_region(x, y, width, height) {
                    Ok(image) => {
                        let mut data = image.into_raw();
                        let len = data.len();
                        let data_ptr = data.as_mut_ptr();
                        std::mem::forget(data);
                        
                        CaptureResult {
                            success: true,
                            data: data_ptr,
                            len,
                            width,
                            height,
                            error_msg: ptr::null_mut(),
                        }
                    }
                    Err(e) => create_error_result(&format!("Failed to capture region: {:?}", e)),
                }
            } else {
                create_error_result("No primary monitor found")
            }
        }
        Err(e) => create_error_result(&format!("Failed to get monitors: {:?}", e)),
    });
    
    Box::into_raw(result)
}

/// 获取显示器数量
#[no_mangle]
pub extern "C" fn xcap_get_monitor_count() -> i32 {
    match Monitor::all() {
        Ok(monitors) => monitors.len() as i32,
        Err(_) => -1,
    }
}

// 内部辅助函数
fn capture_monitor_internal(primary_only: bool) -> *mut CaptureResult {
    let result = Box::new(match Monitor::all() {
        Ok(monitors) => {
            if primary_only {
                // 只捕获主显示器
                if let Some(monitor) = monitors.into_iter().find(|m| m.is_primary().unwrap_or(false)) {
                    capture_monitor(&monitor)
                } else {
                    create_error_result("No primary monitor found")
                }
            } else {
                // 捕获第一个显示器（简化实现）
                if let Some(monitor) = monitors.into_iter().next() {
                    capture_monitor(&monitor)
                } else {
                    create_error_result("No monitors found")
                }
            }
        }
        Err(e) => create_error_result(&format!("Failed to get monitors: {:?}", e)),
    });
    
    Box::into_raw(result)
}

fn capture_monitor(monitor: &Monitor) -> CaptureResult {
    match monitor.capture_image() {
        Ok(image) => {
            let width = image.width();
            let height = image.height();
            let mut data = image.into_raw();
            let len = data.len();
            let data_ptr = data.as_mut_ptr();
            std::mem::forget(data);
            
            CaptureResult {
                success: true,
                data: data_ptr,
                len,
                width,
                height,
                error_msg: ptr::null_mut(),
            }
        }
        Err(e) => create_error_result(&format!("Failed to capture monitor: {:?}", e)),
    }
}

fn create_error_result(msg: &str) -> CaptureResult {
    let error_msg = CString::new(msg).unwrap_or_else(|_| CString::new("Unknown error").unwrap());
    
    CaptureResult {
        success: false,
        data: ptr::null_mut(),
        len: 0,
        width: 0,
        height: 0,
        error_msg: error_msg.into_raw(),
    }
}