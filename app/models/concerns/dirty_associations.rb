module DirtyAssociations
  attr_accessor :dirty 

  def make_dirty(record)
    self.dirty = true
  end

  def changed?
    dirty || super
  end
end