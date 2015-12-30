module ApiHelpers
  def json(object, status: nil)
    res.headers.merge! "Content-Type" => "application/json"
    res.headers.merge! "Accept" => "application/json"
    res.write JSON.dump(object)
    res.status = status unless status.nil?
  end

  def slice(hash, *attributes)
    attributes = attributes.map(&:to_s)
    hash.select { |k, _| attributes.include?(k) }
  end
end