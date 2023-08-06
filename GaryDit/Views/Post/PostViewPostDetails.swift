//
//  PostViewPostDetails.swift
//  GaryDit
//
//  Created by Tom Knighton on 29/07/2023.
//

import Foundation
import SwiftUI
import MarkdownView

struct PostViewPostDetails: View {
    
    @Bindable var viewModel: RedditPostViewModel
    @State private var showMediaUrl: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
                        
            if viewModel.displayMediaBelowTitle == false {
                mediaView()
            }
            Text(viewModel.post.postTitle)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
            if viewModel.displayMediaBelowTitle {
                mediaView()
            }
            
            if let text = viewModel.post.postContent.textContent {
                Spacer().frame(height: 16)
                MarkdownView(text: .constant(text))
            }
            
            self.bottomBar()
        }
        .padding(.horizontal, 12)
        .background(Color.layer1)
        .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 0))
        .fullScreenCover(item: $showMediaUrl, content: { url in
            MediaGalleryView(selectedMediaUrl: url)
                .environment(viewModel)
                .background(BackgroundCleanerView())
        })
        .onChange(of: self.showMediaUrl, initial: true) {
            if let media = self.showMediaUrl, media.isEmpty == false {
                NotificationCenter.default.post(name: .MediaGalleryFullscreenPresented, object: nil, userInfo: ["except": self.showMediaUrl ?? ""])
            } else {
                NotificationCenter.default.post(name: .MediaGalleryFullscreenDismissed, object: nil, userInfo: [:])
            }
        }
    }
    
    @ViewBuilder
    func mediaView() -> some View {
        PostTopMediaView(showMediaUrl: $showMediaUrl, content: viewModel.post.postContent, isSpoiler: viewModel.post.postFlagDetails.isSpoiler)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 3)
            .environment(viewModel)
            .padding(.top, 4)
            .onAppear {
                self.viewModel.overrideVideosDontStopWhenDisappear = true
            }
            .onDisappear {
                self.viewModel.overrideVideosDontStopWhenDisappear = false
            }
    }
    
    @ViewBuilder
    func bottomBar() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("In **\(viewModel.post.postSubreddit)** by **\(viewModel.post.postAuthour)**")
                if viewModel.post.postFlagDetails.isStickied {
                    Text(Image(systemName: "pin.fill"))
                        .foregroundStyle(.green)
                }
                if viewModel.post.postFlagDetails.isLocked {
                    Text(Image(systemName: "lock.fill"))
                        .foregroundStyle(.yellow)
                }
                if viewModel.post.postFlagDetails.isArchived {
                    Text(Image(systemName: "archivebox.fill"))
                        .foregroundStyle(.yellow)
                }
            }
            HStack {
                HStack(spacing: 2) {
                    Text(Image(systemName: "arrow.up"))
                    Text(viewModel.post.postScore.friendlyFormat())
                }
                HStack(spacing: 2) {
                    Text(Image(systemName: "smiley"))
                    Text("\(viewModel.post.postScorePercentage)%")
                }
                HStack(spacing: 2) {
                    Text(Image(systemName: viewModel.hasBeenEdited ? "pencil" : "clock"))
                    Text(viewModel.creationOrEditTime.friendlyAgo)
                }
            }
            
            Divider()
                .overlay(.primary)
            HStack {
                Spacer()
                PostActionButton(systemIcon: "arrow.up", tintColor: .gray, isActive: false)
                Spacer()
                PostActionButton(systemIcon: "arrow.down", tintColor: .gray, isActive: false)
                Spacer()
                PostActionButton(systemIcon: "bookmark", tintColor: .gray, isActive: false)
                Spacer()
                PostActionButton(systemIcon: "arrowshape.turn.up.backward", tintColor: .gray, isActive: false)
                Spacer()
                PostActionButton(systemIcon: "square.and.arrow.up", tintColor: .gray, isActive: false)
                Spacer()
            }
            Divider()
                .overlay(.primary)
        }
        .foregroundStyle(.gray)
    }
}
//
//#Preview {
//    ScrollView {
//        PostViewPostDetails(viewModel: RedditPostViewModel(post: Post(postId: "1", postAuthour: "Banging_Bananas", postSubreddit: "UkPolitics", postTitle: "Daily Megathread", postScore: 100, postScorePercentage: 100, postCreatedAt: Date(), postEditedAt: nil, postCommentCount: 100, postFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: true, isArchived: false, isSpoiler: false, distinguishmentType: .none), postContent: PostContent(contentType: .textOnly, textContent: "---\r\n\r\n**[👋](https://i.imgur.com/h5wkqf4.png) Welcome to /r/ukpolitics' daily megathreads, for light real-time discussion of the day's latest developments.**\r\n\r\n---\r\n\r\n\r\nPlease do not submit articles to the megathread which clearly stand as their own submission. Links as comments are not useful here. Add a headline, tweet content or explainer please.\r\n\r\nThis thread will automatically roll over into a new one at **4,000** comments, and at 06:00 GMT each morning.\r\n\r\nYou can join **[our Discord server](https://discord.gg/DPQERCvzbg)** for real-time discussion with fellow subreddit users, and **[follow our Twitter account](https://twitter.com/rukpoliticsmods)** to keep up with the latest developments.\r\n\r\n---\r\n\r\n###Useful Links\r\n\r\n**** · [**🌎 International Politics Discussion Thread**](https://www.reddit.com/r/ukpolitics/comments/14peq9l/international_politics_discussion_thread/?sort=new)\r\n\r\n[**📺 Daily Parliament Guide**](https://parliamentlive.tv/Guide) . [**📜 Commons**](https://parliamentlive.tv/Commons) . [**📜 Lords**](https://parliamentlive.tv/Lords) . [**📜 Committees**](https://parliamentlive.tv/Committees)\r\n\r\n[**📋 Spring 2023 Subreddit Survey by /u/lets_chill_dude**](https://old.reddit.com/r/ukpolitics/comments/13fqgjf/rukpolitics_spring_23_survey/)\r\n\r\n---", media: []))))
//    }
//    
//}
