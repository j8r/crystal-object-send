require "spec"
require "../src/object_send"

describe "send" do
  describe String do
    it "chars" do
      "abc".send("chars").should eq ['a', 'b', 'c']
    end

    it "size" do
      var = "size"
      "abc".send(var).should eq 3
    end

    it "size()" do
      "abc".send("size()").should eq 3
    end

    it "starts_with? Char" do
      "abc".send("starts_with? 'a'").should be_true
    end

    it "lchop(Char)" do
      "abc".send("lchop('a')").should eq "bc"
    end
  end

  describe Int32 do
    it "- Float" do
      2.send("+ 3.0").should eq 5
    end
  end

  describe Hash do
    it "keys" do
      {"a" => 'b'}.send("keys").should eq ["a"]
    end
  end

  describe Array do
    it "first" do
      [0, 1, 3].send("first 2").should eq [0, 1]
    end
  end
end
