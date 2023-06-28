import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randomy/core/common/error_text.dart';
import 'package:randomy/core/common/loader.dart';
import 'package:randomy/features/auth/controlller/auth_controller.dart';
import 'package:randomy/features/community/controller/community_controller.dart';


class showCommunityMembers extends ConsumerStatefulWidget {
  final String name;
  const showCommunityMembers({super.key,required this.name,});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _showCommunityMembersState();
}

class _showCommunityMembersState extends ConsumerState<showCommunityMembers> {
  Set<String> uids = {};
  int ctr = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Members'),
        actions: [],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (BuildContext context, int index) {
                final member = community.members[index];

                return ref.watch(getUserDataProvider(member)).when(
                      data: (user) {
                        if (community.mods.contains(member) && ctr == 0) {
                          uids.add(member);
                        }
                        ctr++;
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                            
                            } else {
                              
                            }
                          },
                          title: Text(user.name),
                          secondary: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          user.profilePic,
                                        ),
                                        radius: 16,
                                      ),

                          

                        );
                      },
                      error: (error, stackTrace) => ErrorText(
                        error: error.toString(),
                      ),
                      loading: () => const Loader(),
                    );
              },
            ),
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}


