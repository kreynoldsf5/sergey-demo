resource "volterra_origin_pool" "op" {
  name                   = format("%s-op", var.base)
  namespace              = var.ns
  description            = format("Origin pool pointing to arbitrary URL.")
  loadbalancer_algorithm = "LB_OVERRIDE"
  endpoint_selection     = "LOCAL_PREFERRED"
  origin_servers {
    public_name {
        dns_name = var.origin_fqdn
    }
  }
  port               = 443
  use_tls {
      tls_config {
          default_security = true
      }
      no_mtls = true
  }
}

resource "volterra_app_firewall" "af" {
  name        = format("%s-app-firewall", var.base)
  description = format("App Firewall in blocking mode for %s", var.base)
  namespace   = var.ns

  allow_all_response_codes = true
  default_anonymization = true
  use_default_blocking_page = true
  default_bot_setting = true
  default_detection_settings = true
  blocking = true
}

resource "volterra_http_loadbalancer" "lb" {
  name                            = format("%s-lb", var.base)
  namespace                       = var.ns
  description                     = format("HTTPS loadbalancer object for %s origin server", var.base)
  domains                         = [var.app_fqdn]
  advertise_on_public_default_vip = true
  round_robin                     = true
  default_route_pools {
    pool {
      name      = volterra_origin_pool.op.name
      namespace = var.ns
    }
  }
  https_auto_cert {
    add_hsts              = false
    http_redirect         = true
    no_mtls               = true
    enable_path_normalize = true
  }
  multi_lb_app = false
  app_firewall {
    name      = volterra_app_firewall.af.name
    namespace = var.ns
  }
  bot_defense {
    policy {
      disable_js_insert       = false
      js_insert_all_pages {
        javascript_location  = "After <head> tag"
      }
      protected_app_endpoints {
        any_domain = true
        path {
          prefix = "/cart"
        }
        protocol = "https"
        web  = true
        http_methods = ["POST"]
        metadata {
          name = format("%s-bot-defense", var.base)
        }
        mitigation {
          block {
            body = "string:///PHA+VGhpcyBpcyBhIGJvdCBkZWZlbnNlIGJsb2NrIHBhZ2UuPC9wPg==" 
            #<p>This is a bot defense block page.</p>"
            status = "BadRequest"
          }
        }
      }
    }
    timeout = 1000
    regional_endpoint = var.bot_defense_region
  }
  disable_rate_limit              = true
  service_policies_from_namespace = true
  no_challenge                    = true
  add_location                    = true
}