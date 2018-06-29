require "sinatra"

#
# 2. La indemnización por años de servicio
#
# Nota
# Si la fracción es superior a 6 meses, se tiene derecho a otra remuneración por 30 días
# No contempla el máximo de días de salario
#
def compensation(salary, worked_months)
  total = 0

  if worked_months >= 12
    years = worked_months / 12
    has_fraction = worked_months - (12 * years) >= 6
    total += salary * (years + (has_fraction ? 1 : 0))
  end

  total
end


#
# 2. Retorna el número de días progresivos
#
def progressive_holiday(current_date, years_of_service_with_other_employers, recruitment_date_of_last_employer)
  worker_years_with_last_employer = ((current_date - recruitment_date_of_last_employer) / 365).to_i
  total_worker_years = years_of_service_with_other_employers.sum + worker_years_with_last_employer

  if worker_years_with_last_employer >= 3 && total_worker_years >= 10 + 3
    (total_worker_years - 10) / 3
  else
    0
  end
end


def format_number(n)
  n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
end

get '/' do
  erb :index
end

post "/compensation" do
  begin
    salary = params["salary"].to_i
    worked_months = params["worked_months"].to_i
    result = compensation(salary,worked_months )

    case result
    when 0 then "No tiene indemnización"
    else "Monto a pagar por indemnización <div>#{format_number salary} * #{worked_months} meses = $ #{format_number result} pesos</div>"
    end
  rescue
    halt 400, "Debe llenar todos los campos correctamente"
  end
end

post "/progressive_holiday" do
  begin
    current_date = DateTime.strptime(params["current_date"], "%d/%m/%Y")
    years_of_service_with_other_employers = params["years_of_service_with_other_employers"].to_a.map { |n| n.to_i }
    recruitment_date_of_last_employer = DateTime.strptime(params["recruitment_date_of_last_employer"], "%d/%m/%Y")

    result = progressive_holiday(current_date, years_of_service_with_other_employers, recruitment_date_of_last_employer)
    case result
    when 0 then "No tiene días progresivos"
    when 1 then "Tiene 1 día progresivo"
    else "Tiene #{format_number result} días progresivos"
    end
  rescue
    halt 400, "Debe llenar todos los campos correctamente"
  end
end
