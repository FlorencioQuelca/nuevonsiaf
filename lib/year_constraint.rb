class YearConstraint

  def self.matches?(request)
    years = EntrySubarticle.years_not_closed
    years.include?(request.params[:year].to_i)
  end

end