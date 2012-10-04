class SuperModel
  
  def to_pdf
    @x = 1
    Prawnder::ModelRenderer.to_string "test/default_render", self
  end
  
end