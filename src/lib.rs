use proxy_wasm::traits::*;
use proxy_wasm::types::*;
use serde_json::{Value};

use std::collections::HashMap;


#[no_mangle]
pub fn _start() {
    proxy_wasm::set_log_level(LogLevel::Trace);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> {
        Box::new(HeaderAppendRootContext{
            headers: HashMap::new()
        })
    });
}

struct HeaderAppendFilter{
    headers: HashMap<String, String>
}

impl Context for HeaderAppendFilter {}

impl HttpContext for HeaderAppendFilter {

    fn on_http_response_headers(&mut self, _num_headers: usize) -> Action {
        for (key, value) in &self.headers {
            self.add_http_response_header(key, value);
        }
        
        Action::Continue
    }
}

struct HeaderAppendRootContext {
    headers: HashMap<String, String>
}

impl Context for HeaderAppendRootContext {}

impl RootContext for HeaderAppendRootContext {
    
    fn on_vm_start(&mut self, _vm_configuration_size: usize) -> bool {
        true
    }

    fn on_configure(&mut self, _plugin_configuration_size: usize) -> bool {
        if let Some(config_bytes) = self.get_configuration() {
            let config: Value = serde_json::from_slice(config_bytes.as_slice()).unwrap();
            let mut m = HashMap::new();
            for (key, value) in config.as_object().unwrap().iter() {
                m.insert(key.to_owned(), value.to_string());
            }
            self.headers = m
        }
        true
    }

    fn create_http_context(&self, _context_id: u32) -> Option<Box<dyn HttpContext>> {
        Some(Box::new(HeaderAppendFilter{
            headers: self.headers.clone(),
        }))
    
    }

    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }

}
