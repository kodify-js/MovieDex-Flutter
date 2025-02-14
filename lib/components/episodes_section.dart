import 'package:flutter/material.dart';
import 'package:moviedex/api/api.dart';
import 'package:moviedex/api/class/content_class.dart';
import 'package:moviedex/api/class/episode_class.dart';
import 'package:moviedex/components/episodes_list.dart';

class EpisodesSection extends StatefulWidget {
  final Contentclass data;
  final int initialSeason;
  const EpisodesSection({super.key, required this.data, this.initialSeason = 1});

  @override
  State<EpisodesSection> createState() => _EpisodesSectionState();
}

class _EpisodesSectionState extends State<EpisodesSection> {
  final Api api = Api();
  late int selectedSeason;
  List<Episode>? episodes;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    selectedSeason = widget.initialSeason;
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => isLoading = true);
    try {
      final newEpisodes = await api.getEpisodes(
        id: widget.data.id,
        season: selectedSeason,
      );
      setState(() {
        episodes = newEpisodes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildEpisodeCard(BuildContext context, Episode episode) {
    return Card(
      color: Colors.grey[900],
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 160,
              height: 90,
              child: episode.image != null && episode.image.isNotEmpty
                ? Image.network(
                    episode.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
            ),
          ),
          // ...rest of episode card...
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: selectedSeason,
              dropdownColor: Theme.of(context).colorScheme.secondary,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSecondary),
              underline: SizedBox(),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold
              ),
              items: List.generate(
                widget.data.seasons?.length ?? 1,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Season ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null && value != selectedSeason) {
                  setState(() => selectedSeason = value);
                  _loadEpisodes();
                }
              },
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Episodes",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (episodes != null)
            ListView.builder(
              itemCount: episodes!.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return EpisodesList(
                  episode: episodes![index],
                  data: widget.data,
                );
              },
            ),
        ],
      ),
    );
  }
}
