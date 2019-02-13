class Object
  def send(call : String)
    send call.strip
  end

  macro send(call)
    {% supported_types = %w(String Int Char Nil Float64) %}
    {% arg_count = [1, 2, 3, 4] %}
    cast = -> (string : String) {
      if string.starts_with?('"') && string.ends_with?('"')
        string.lchop.rchop
      elsif int32 = string.to_i?
        int32
      elsif float64 = string.to_f?
        float64
      elsif (string.size == 3) && string.starts_with?('\'') && string.ends_with?('\'')
        string[1]
      else
        raise "unsupported type: " + string
      end
    }
    arg1 = arg2 = arg3 = arg4 = nil
    arg_number = 0
    if {{call.id}}.ends_with? ')'
      method, str_args = {{call.id}}.rchop(')').split('(', limit: 2)
    elsif {{call.id}}.includes? ' '
      method, str_args = {{call.id}}.split(' ', limit: 2)
    else
      method = {{call.id}}
    end
      
    if str_args
      if str_args.includes?(',')
        str_args.split(',') do |val|
          arg_number += 1
          case arg_number
          {% for arg_num in arg_count %}
          when {{arg_num.id}} then arg{{arg_num.id}} = cast.call val
          {% end %}
          else        raise "the current max number of arguments is {{arg_count.last.id}}: " + val
          end
        end
      elsif !str_args.empty?
        arg_number = 1
        arg1 = cast.call str_args
      end
    end
    
    method_with_args = case arg_number
    when 0 then { method }
    when 1 then { method, arg1 }
    when 2 then { method, arg1, arg2 }
    when 3 then { method, arg1, arg2, arg3 }
    when 4 then { method, arg1, arg2, arg3, arg4 }
    else       raise "max number of arguments reached: {{arg_count.last.id}}"
    end

    case method_with_args
    {% methods = @type.methods %}\
    {% for type in @type.ancestors %}\
      {% methods = methods + type.methods %}\
    {% end %}\
    {% used_methods = {} of String => Bool? %}\
    {% for method in methods %}
      {% if method.accepts_block? ||
              used_methods[method.name.stringify + method.args.map(&.restriction.stringify).join("")] ||
              (method.name.size > 1 && method.name.size < 4) ||
              method.name == "transpose" ||
              method.name == "product" ||
              method.name == "to_h" ||
              method.name.ends_with?('=') %}\
      # {{method.name}} {{method.args}}
      {% elsif method.args.empty? %}\
      when { {{method.name.stringify}} }
        self.{{method.name}}
        {% used_methods[method.name.stringify] = true %}\
      {% elsif method.args.size < 5 && method.args.all? { |t| supported_types.includes? t.restriction.stringify } %}\
      {% method_args = "" %}\
      when { {{method.name.stringify}} {% for arg in method.args %}\
              , {{arg.restriction}}\
              {% method_args = method_args + arg.restriction.stringify %}\
          {% end %}\ }
          {% i = 0 %}
          self.{{method.name}}(
          {% for arg in method.args %}{% i = i + 1 %}arg{{i.id}}.as({{arg.restriction}}), {% end %}\
          )
        {% used_methods[method.name.stringify + method_args] = true %}\
        {% end %}\
      {% end %}\
    else
      raise "unsupported method: #{method_with_args}"
    end
  end
end
