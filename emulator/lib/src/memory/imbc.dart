// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:00:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class IMbc {

  int	pullMem(int memAddr);
  void	pushMem(int memAddr, int v);

}