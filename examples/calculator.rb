class Calculator
  def add(a, b)
    binding.pry
    a + b
  end

  def subtract(a, b)
    # debugger
    a - b
  end

  def multiply(a, b)
    a * b
    # binding.irb
  end

  def divide(a, b)
    return 0 if b == 0
    binding.break
    a / b
  end
end
