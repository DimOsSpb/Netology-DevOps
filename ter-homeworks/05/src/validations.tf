variable "ip_address" {
    type=string
    description="ip-адрес"
    # Тесты:  "192.168.0.1" и "1920.1680.0.1"
    default = "192.168.0.1"
    validation {
      condition = can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$", var.ip_address))
      error_message = "Invalid ip4 address!"
    }
}

variable "ip_address_list" {
    type=list(string)
    description="список ip-адресов"
    # Тесты:  ["192.168.0.1", "1.1.1.1", "127.0.0.1"] и ["192.168.0.1", "1.1.1.1", "1270.0.0.1"]
    default = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]
    validation {
      condition = alltrue([ for i in var.ip_address_list : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$", i)) ])
      error_message = "Invalid ip4 address!"
    }
}


# *********************

variable "any_string" {
    type=string
    description="любая строка"

    default = "hello - 1!"
    validation {
      #condition = can(regex("[a-z]|[а-я]", var.any_string))
      condition = var.any_string == lower(var.any_string)
      error_message = "Invalid string register!"
    }
}

variable "in_the_end_there_can_be_only_one" {
    description="Who is better Connor or Duncan?"
    type = object({
        Dunkan = optional(bool)
        Connor = optional(bool)
    })

    default = {
        Dunkan = true
        Connor = true
    }

    validation {
        error_message = "There can be only one MacLeod"
        condition = var.in_the_end_there_can_be_only_one.Dunkan != var.in_the_end_there_can_be_only_one.Connor
    }
}