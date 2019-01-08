describe TableBuilderHelper::CustomLinks do
  describe "#polymorphic_url" do
    it "returns the correct URL path for Companies#show" do
      company = build_stubbed(:company)
      user_context = UserContext.new(build_stubbed(:user))

      expect(
        TableBuilderHelper::CustomLinks.new(
          company,
          user_context,
          [:show],
          company.line_referential
        ).polymorphic_url(:show)
      ).to eq([company.line_referential, company])
    end
  end

  describe "#authorized_actions" do
    before do
      allow_any_instance_of(ReferentialPolicy).to receive(:show?){ true }
    end

    it "includes :show" do
      referential = build_stubbed(:referential)
      user_context = UserContext.new(
        build_stubbed(
          :user,
          organisation: referential.organisation,
        ),
        referential: referential
      )

      expect(
        TableBuilderHelper::CustomLinks.new(
          referential,
          user_context,
          [:show]
        ).authorized_actions
      ).to eq([:show])
    end
  end
end
