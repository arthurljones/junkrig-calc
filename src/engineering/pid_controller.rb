class PIDController
  def initialize(options)
    @proportional_coefficient = options[:p] || 1
    @integral_coefficient = options[:i] || 0
    @derivative_coefficient = options[:d] || 0
    @error_derivator_weight = options[:d_avg_weight] || 0.2

    zero = options[:zero] || 0
    @prev_error = zero
    @error_derivator = zero
    @error_integrator = zero
  end

  def step(error)
    error_slope = error - @prev_error
    @prev_error = error
    @error_derivator = @error_derivator * (1 - @error_derivator_weight) + error_slope * @error_derivator_weight
    @error_integrator += error

    proportional = error * @proportional_coefficient
    integral = @error_integrator * @integral_coefficient
    derivative = @error_derivator * @derivative_coefficient

    -(proportional + integral + derivative)
  end
end
