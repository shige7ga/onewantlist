RSpec.shared_examples "contentの共通バリデーション" do |factory|
  {
    "nil" => nil,
    "空文字" => "",
    "スペースのみ" => " 　 ",
    "TABのみ" => "\t\t"
  }.each do |name, value|
    it "#{name}の場合は無効" do
      expect(build(factory, content: value)).to be_invalid
    end
  end

  it "前後の空白を除去する" do
    record = build(factory, content: "  Railsの勉強  ")
    expect(record.content).to eq("Railsの勉強")
  end

  it "400文字なら有効" do
    expect(build(factory, content: "a" * 400)).to be_valid
  end

  it "401文字なら無効" do
    expect(build(factory, content: "a" * 401)).to be_invalid
  end
end
