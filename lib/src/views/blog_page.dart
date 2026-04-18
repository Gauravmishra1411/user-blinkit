import 'package:flutter/material.dart';

class BlogPost {
  final String title;
  final String date;
  final String excerpt;
  final String imageUrl;

  BlogPost({
    required this.title,
    required this.date,
    required this.excerpt,
    required this.imageUrl,
  });
}

class BlogPage extends StatelessWidget {
  final bool isDarkMode;
  
  BlogPage({super.key, required this.isDarkMode});

  final List<BlogPost> posts = [
    BlogPost(
      title: 'Revolutionizing Team Collaboration: The CollabNex Way',
      date: 'Apr 8, 2022',
      excerpt: 'Discover how CollabNex is changing the game in team collaboration, boosting productivity and sparking creativity.',
      imageUrl: 'https://images.unsplash.com/photo-1522071823991-b1ae5e6a3048?w=800&q=80',
    ),
    BlogPost(
      title: 'Unleashing Creativity: How CollabNex Inspires Innovation',
      date: 'Mar 15, 2022',
      excerpt: 'Explore how CollabNex nurtures a culture of creativity, empowering teams to unleash their full innovative potential.',
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80',
    ),
    BlogPost(
      title: 'Efficiency Redefined: The Power of CollabNex Task Management',
      date: 'Feb 28, 2022',
      excerpt: "Learn how CollabNex's task management features streamline workflows, increase efficiency, and keep projects on track.",
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    ),
    BlogPost(
      title: 'Data-Driven Decision-Making: Insights from CollabNex Analytics',
      date: 'Feb 6, 2022',
      excerpt: 'Unlock the power of data with CollabNex Analytics, empowering teams to make informed decisions and drive success.',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    ),
    BlogPost(
      title: 'Empowering Remote Teams: The CollabNex Advantage',
      date: 'Jan 12, 2022',
      excerpt: 'Discover how CollabNex bridges the gap for remote teams, fostering collaboration and productivity from anywhere.',
      imageUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=800&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Blog', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3D2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Buy Template', style: TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Blog Articles',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Stay informed and inspired with our blog, featuring insightful\narticles and updates on a variety of topics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // Blog Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 40,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _buildBlogCard(posts[index], isDarkMode),
                  );
                },
              ),
            ),

            const SizedBox(height: 80),

            // CTA Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                color: const Color(0xFF1B3D2F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Accelerate. Empower.\nCollaborate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your next big collaborative platform to accelerate your workflow.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                    child: const Text('Start a free trial'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
            
            // Minimal Footer
            _buildMinimalFooter(isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(BlogPost post, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(post.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Date
        Text(
          post.date,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Title
        Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        // Excerpt
        Text(
          post.excerpt,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalFooter(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 24, color: Colors.green),
              const SizedBox(width: 8),
              Text('CollabNex', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            ],
          ),
          Row(
            children: [
              _footerText('Features', isDarkMode),
              const SizedBox(width: 24),
              _footerText('About', isDarkMode),
            ],
          )
        ],
      ),
    );
  }

  Widget _footerText(String label, bool isDarkMode) {
    return Text(
      label,
      style: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black54,
        fontSize: 14,
      ),
    );
  }
}
