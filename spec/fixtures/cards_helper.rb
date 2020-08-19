module CardsHelper
  CARDS = {
    usual: UsualCard.new,
    capitalist: CapitalistCard.new,
    virtual: VirtualCard.new
  }.freeze
end
